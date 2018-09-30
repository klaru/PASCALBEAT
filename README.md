# PASCALBEAT
Board Electrical Analysis Tool (BEAT) in Free Pascal

(*               BOARD ELECTRICAL ANALYSIS TOOL (BEAT)                       *
*                             7-1-88                                         *
*                                                                            *
*  This is a program which assist the engineer in dealing with transmission  *
*  line issues such as the line impedance, propagation delay, reflection     *
*  coefficient, distributed capacitance, etc.                                *
*                                                                            *
*  Modifications to BEAT:                                                    *
*  6/89, Ulf Schlichtmann                                                    *
*  Comments on details of the modifications appear throughout the program    *
*									                                                           *
*  8/1989, Klaus Ruff							                                           *
*  Ported to Turbo-Pascal 5 on PC					                                   *
*  4/1991 Klaus Ruff								                                         *
*  Ported to Turbo Pascal Windows (Text Mode)                                *
*  9/2018 Klaus Ruff                                                         +
*  Ported to Free Pascal 3.0 (Text Mode)                                     *
*                                                                            *
*  Key Global Variables:                                                     *
*                                                                            *
* IntImped (ohms)	= Intrinsic impedance of a line (no dist. cap.)          *
*	EffImped (ohms)	= Effective impedance after dist. cap. considered.         *
*	IntProp (ns/ft)= Intrinsic prop. delay of a line (no dist. cap.)           *
*	EffProp (ns/ft)= Effective prop. delay after dist. cap. considered.        *
*	IntCap (pf/in)	= Intrinsic capacitance of the line.                       *
*	DistCap	(pf/in)	= Extra capacitance distributed along a line.              *
*	IntInd (nH/in)	= Intrinsic inductance of the line.                        *
*	IntRes (ohms/in)= Intrinsic resistance of the line.                        *
*                                                                            *
******************************************************************************)
