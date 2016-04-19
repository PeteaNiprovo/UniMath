Require Import UniMath.Foundations.Basics.PartD.
Require Import UniMath.Foundations.Basics.Propositions.
Require Import UniMath.Foundations.Basics.Sets.
Require Import UniMath.Foundations.NumberSystems.NaturalNumbers.

Require Import UniMath.CategoryTheory.total2_paths.
Require Import UniMath.CategoryTheory.precategories.
Require Import UniMath.CategoryTheory.functor_categories.
Require Import UniMath.CategoryTheory.UnicodeNotations.
Require Import UniMath.CategoryTheory.limits.graphs.colimits.
Require Import UniMath.CategoryTheory.category_hset.
Require Import UniMath.CategoryTheory.category_hset_structures.
Require Import UniMath.CategoryTheory.limits.initial.
Require Import UniMath.CategoryTheory.FunctorAlgebras.
Require Import UniMath.CategoryTheory.limits.FunctorsPointwiseProduct.
Require Import UniMath.CategoryTheory.limits.FunctorsPointwiseCoproduct.
Require Import UniMath.CategoryTheory.limits.products.
Require Import UniMath.CategoryTheory.limits.coproducts.
Require Import UniMath.CategoryTheory.limits.terminal.
Require Import UniMath.CategoryTheory.limits.cats.limits.
Require Import UniMath.CategoryTheory.chains.
Require Import UniMath.CategoryTheory.ProductPrecategory.
Require Import UniMath.CategoryTheory.equivalences.
Require Import UniMath.CategoryTheory.EquivalencesExamples.
Require Import UniMath.CategoryTheory.AdjunctionHomTypesWeq.
Require Import UniMath.CategoryTheory.polynomialfunctors.
Require Import UniMath.CategoryTheory.exponentials.

Local Notation "# F" := (functor_on_morphisms F) (at level 3).
Local Notation "[ C , D , hs ]" := (functor_precategory C D hs).

Ltac etrans := eapply pathscomp0.

Section rightkanextension.

Require Import UniMath.CategoryTheory.whiskering.
Require Import UniMath.CategoryTheory.RightKanExtension.
Require Import UniMath.CategoryTheory.CommaCategories.

Variables M C A : precategory.
Variables (K : functor M C).
Variables (hsC : has_homsets C) (hsA : has_homsets A).
Variables (LA : Lims A).

Local Notation "c ↓ K" := (cComma hsC K c) (at level 30).

Section fix_T.

Variable (T : functor M A).

Local Definition Q (c : C) : functor (c ↓ K) M := cComma_pr1 hsC K c.

Local Definition QT (c : C) := functor_composite (Q c) T.

Local Definition R (c : C) := lim (LA _ (QT c)).

Local Definition lambda (c : C) : cone (QT c) (R c) := limCone (LA _ (QT c)).

Local Definition Rmor_cone (c c' : C) (g : C⟦c,c'⟧) : cone (QT c') (R c).
Proof.
use mk_cone.
- intro m1f1.
  transparent assert (m1gf1 : (c ↓ K)).
  { mkpair.
    + apply (pr1 m1f1).
    + apply (g ;; pr2 m1f1). }
  exact (coneOut (lambda c) m1gf1).
- intros x y f; simpl in *.
  transparent assert (e : ((c ↓ K) ⟦ pr1 x,, g ;; pr2 x, pr1 y,, g ;; pr2 y ⟧)).
  { mkpair.
    + apply (pr1 f).
    + abstract (now rewrite <- assoc, (pr2 f)). }
  exact (coneOutCommutes (lambda c) _ _ e).
Defined.

Local Definition Rmor (c c' : C) (g : C⟦c,c'⟧) : A⟦R c,R c'⟧.
Proof.
use limArrow.
apply (Rmor_cone _ _ g).
Defined.

Local Definition R_data : functor_data C A := R,,Rmor.

Local Definition R_functor : functor C A.
Proof.
apply (tpair _ R_data).
mkpair.
- intros c; simpl.
  apply pathsinv0, limArrowUnique.
  intro c'; simpl.
  rewrite !id_left.
  now destruct c'.
- intros c c' c'' f f'; simpl.
  apply pathsinv0, limArrowUnique.
intros x.
simpl.
unfold lambda.
rewrite <- assoc.
unfold Rmor.
simpl.
etrans.
apply maponpaths.
apply (limArrowCommutes (LA _ (QT c'')) (R c') (Rmor_cone c' c'' f')).
etrans.
apply (@limArrowCommutes _ _ _ (LA _ (QT c')) (R c) (Rmor_cone c c' f) (pr1 x,,f' ;; pr2 x)).
destruct x.
rewrite <- assoc.
apply idpath.
Defined.

Local Definition eps_n (n : M) : A⟦R_functor (K n),T n⟧ :=
  coneOut (lambda (K n)) (n,,identity (K n)).

Definition eps : [M,A,hsA]⟦functor_composite K R_functor,T⟧.
Proof.
mkpair.
- apply eps_n.
-
intros n n' h; simpl.
set (X := # R_functor (# K h)).
simpl in X.
unfold Rmor in *.
simple refine (let temp : K n' ↓ K := _ in _).
  mkpair.
  apply n'.
  apply identity.
eapply pathscomp0.
apply (limArrowCommutes (LA (K n' ↓ K) (QT (K n'))) (R (K n))
       (Rmor_cone (K n) (K n') (# K h)) temp).
simpl.
unfold eps_n.
simpl.
transparent assert (u : (K n ↓ K)).
  apply (n,, identity (K n)).
transparent assert (v : (K n ↓ K)).
  apply (n',, # K h ;; identity (K n')).
transparent assert (e : (K n ↓ K ⟦ u, v ⟧)).
  mkpair.
  apply h.
  now rewrite id_left, id_right.
apply pathsinv0; eapply pathscomp0.
 apply (coneOutCommutes (lambda (K n)) u v e).
apply idpath.
Defined.

End fix_T.


(* Definition Cone_by_precompose {C1 D1 : precategory} (F : functor C1 D1) *)
(*  (c : D1) (cc : cone F c) (d : D1) (k : D1⟦d,c⟧) : cone F d. *)
(* Proof. *)
(* mkpair. *)
(* intros x. *)
(* apply coneOut. *)
(* now exists (λ u, coconeIn cc u ;; k); apply Cocone_postcompose. *)
(* Defined. *)

Lemma foo : GlobalRightKanExtensionExists _ _ K _ hsC hsA.
Proof.
unfold GlobalRightKanExtensionExists.
use adjunction_from_partial.
- apply R_functor.
- apply eps.
- intros T S α.
mkpair.
+ mkpair.
* simpl in *.

transparent assert (cc : (forall c, cone (QT T c) (S c))).
{
intro c.
use mk_cone.
+ intro mf.
apply (# S (pr2 mf) ;; α (pr1 mf)).
+ abstract (intros fm fm' h;
simpl;
rewrite <- assoc;
eapply pathscomp0;
[apply maponpaths, (pathsinv0 (nat_trans_ax α _ _ (pr1 h)))|];
simpl;
rewrite assoc, <- functor_comp;
apply cancel_postcomposition, maponpaths, (pr2 h)).
}
transparent assert (σ : (forall c, A ⟦ S c, R T c ⟧)).
{ intro c; apply (limArrow _ _ (cc c)). }
{
mkpair.
- apply σ.
- intros c c' g; simpl.
set (H1 := limArrowCommutes (LA (c' ↓ K) (QT T c')) (S c') (cc c')).
(* set (H2 := limArrowCommutes (LA (c ↓ K) (QT T c)) (S c) (cc c)). *)
set (H3 := limArrowCommutes (LA (c' ↓ K) (QT T c')) (R T c) (Rmor_cone T c c' g)).
simpl in *.
set (lambda' := fun mf' => limOut (LA (c' ↓ K) (QT T c')) mf').
assert (H : forall mf' : c' ↓ K,
  (# S g ;; σ c' ;; lambda' mf' = σ c ;; Rmor T c c' g ;; lambda' mf')).
{ intros mf'.
eapply pathscomp0.
Focus 2.
eapply pathsinv0.
rewrite <- assoc.
eapply maponpaths.
apply (H3 mf').
clear H3.
rewrite <- assoc.
eapply pathscomp0.
eapply maponpaths.
apply (H1 mf').
rewrite assoc.
rewrite <- functor_comp.
unfold σ.
set (H2 := limArrowCommutes (LA (c ↓ K) (QT T c)) (S c) (cc c)).
transparent assert (mf : (c ↓ K)).
  mkpair.
  apply (pr1 mf').
  apply (g ;; pr2 mf').
apply pathsinv0.
eapply pathscomp0.
apply (H2 mf).
apply idpath.
}
(* need lemma *)
admit.
}
* admit.
+ admit.
Admitted.

Lemma cocont_pre_composition_functor:
  is_cocont (pre_composition_functor _ _ _ hsC hsA K).
Proof.
apply left_adjoint_cocont.
- apply foo.
- apply functor_category_has_homsets.
- apply functor_category_has_homsets.
Qed.

Lemma omega_cocont_pre_composition_functor :
  omega_cocont (pre_composition_functor _ _ _ hsC hsA K).
Proof.
intros c L ccL.
apply cocont_pre_composition_functor.
Defined.

End rightkanextension.

Section lambdacalculus.


Definition option_functor : [HSET,HSET,has_homsets_HSET].
Proof.
apply coproduct_functor.
apply CoproductsHSET.
apply (constant_functor _ _ unitHSET).
apply functor_identity.
Defined.

(* TODO: package omega cocont functors *)
Definition LambdaFunctor : functor [HSET,HSET,has_homsets_HSET] [HSET,HSET,has_homsets_HSET].
Proof.
eapply sum_of_functors.
  apply (Coproducts_functor_precat _ _ CoproductsHSET).
  apply (constant_functor [HSET, HSET, has_homsets_HSET] [HSET, HSET, has_homsets_HSET] (functor_identity HSET)).
eapply sum_of_functors.
  apply (Coproducts_functor_precat _ _ CoproductsHSET).
  (* app *)
  eapply functor_composite.
    apply delta_functor.
    apply binproduct_functor.
    apply (Products_functor_precat _ _ ProductsHSET).
(* lam *)
apply (pre_composition_functor _ _ _ _ _ option_functor).
Defined.

(* Bad approach *)
(* Definition Lambda : functor [HSET,HSET,has_homsets_HSET] [HSET,HSET,has_homsets_HSET]. *)
(* Proof. *)
(* eapply functor_composite. *)
(*   apply delta_functor. *)
(* eapply functor_composite. *)
(*   eapply product_of_functors. *)
(*     apply functor_identity. *)
(*     apply delta_functor. *)
(* eapply functor_composite. *)
(*   eapply product_of_functors. *)
(*     apply (constant_functor [HSET, HSET, has_homsets_HSET] [HSET, HSET, has_homsets_HSET] (functor_identity HSET)). *)
(*     eapply product_of_functors. *)
(*       apply delta_functor. *)

Lemma omega_cocont_LambdaFunctor : omega_cocont LambdaFunctor.
Proof.
apply omega_cocont_sum_of_functors.
  apply (Products_functor_precat _ _ ProductsHSET).
  apply functor_category_has_homsets.
  apply functor_category_has_homsets.
  apply omega_cocont_constant_functor.
  apply functor_category_has_homsets.
apply omega_cocont_sum_of_functors.
  apply (Products_functor_precat _ _ ProductsHSET).
  apply functor_category_has_homsets.
  apply functor_category_has_homsets.
  apply omega_cocont_functor_composite.
  apply functor_category_has_homsets.
  apply omega_cocont_delta_functor.
  apply (Products_functor_precat _ _ ProductsHSET).
  apply functor_category_has_homsets.
  apply omega_cocont_binproduct_functor.
  apply functor_category_has_homsets.
  apply has_exponentials_functor_HSET.
  apply has_homsets_HSET.
apply omega_cocont_pre_composition_functor.
admit.
Admitted.

End lambdacalculus.