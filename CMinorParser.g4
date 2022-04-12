/*
 * compatible with ACSL language grammar v1.17
 */

parser grammar CMinorParser;

options {
	tokenVocab = CMinorLexer;
}

@header {#pragma warning disable 3021}

// TODO: logic function

/* top level */
main: def* EOF;

def: funcDef | structDef | predDef;

funcDef:
	funcContract (type | 'void') IDENT '(' (para (',' para)*)? ')' '{' (
		decl
		| stmt
	)* '}';

structDef: 'struct' IDENT '{' (atomicType IDENT ';')* '}' ';';

/* variable */
var:
	atomicType IDENT						# atomicVar
	| IDENT IDENT							# structVar
	| atomicType IDENT '[' INT_CONSTANT ']'	# arrayVar;

para:
	atomicType IDENT			# atomicPara
	| IDENT IDENT				# structPara
	| atomicType IDENT '[' ']'	# arrayPara;

/* type */
type: atomicType | IDENT;

atomicType: 'int' | 'float' | 'bool';

/* about statement */
stmt:
	';'										# EmptyStmt
	| expr ';'								# ExprStmt
	| assign ';'							# AssignStmt
	| 'if' '(' expr ')' stmt ('else' stmt)?	# IfStmt
	| loopAnnot iter						# IterStmt
	| 'break' ';'							# BreakStmt
	| 'continue' ';'						# ContStmt
	| 'return' expr? ';'					# ReturnStmt
	| assertion								# assertStmt
	| '{' (stmt | decl)* '}'				# StmtBlock;

iter:
	'while' '(' expr ')' stmt								# WhileStmt
	| 'do' stmt 'while' '(' expr ')'						# DoStmt
	| 'for' '(' forInit? ';' expr? ';' forIter? ')' stmt	# ForStmt;

forInit: var ('=' expr)? | assign;

forIter: assign | expr;

assign:
	IDENT '=' expr					# VarAssign
	| IDENT '[' expr ']' '=' expr	# SubAssign
	| IDENT '.' IDENT '=' expr		# MemAssign;

decl: var ('=' expr)? ';';

/* about expression */
expr:
	IDENT									# IdentExpr
	| constant								# ConstExpr
	| IDENT '(' (expr (',' expr)*)? ')'		# CallExpr
	| '(' expr ')'							# ParExpr
	| expr '[' expr ']'						# SubExpr
	| expr '.' IDENT						# MemExpr
	| ('!' | '-') expr						# UnaryExpr
	| expr ('*' | '/' | '%') expr			# MulExpr
	| expr ('+' | '-') expr					# AddExpr
	| expr ('<' | '<=' | '>' | '>=') expr	# InequExpr
	| expr ('==' | '!=') expr				# EquExpr
	| expr '&&' expr						# AndExpr
	| expr '||' expr						# OrExpr;

/* annotation */
logicConstant:
	INT_CONSTANT
	| FLOAT_CONSTANT
	| '\\true'
	| '\\false';

term:
	IDENT											# IdentTerm
	| '\\result'									# ResTerm
	| logicConstant									# ConstTerm
	| IDENT '(' (term (',' term)*)? ')'				# CallTerm
	| '\\length' '(' term ')'						# LengthTerm
	| '\\old' '(' term ')'							# OldTerm
	| '(' term ')'									# ParTerm
	| '{' term '\\with' '[' term ']' '=' term '}'	# arrayUpdTerm
	| term '[' term ']'								# SubTerm
	| term '.' IDENT								# MemTerm
	| ('!' | '-') term								# UnaryTerm
	| term ('*' | '/' | '%') term					# MulTerm
	| term ('+' | '-') term							# AddTerm
	| term ('<' | '<=' | '>' | '>=') term			# InequTerm
	| term ('==' | '!=') term						# EquTerm
	| term '&&' term								# AndTerm
	| term '||' term								# OrTerm;

pred:
	'\\true'													# TruePred
	| '\\false'													# FalsePred
	| term (('<' | '<=' | '>' | '>=' | '==' | '!=') term)+		# CmpPred
	| IDENT ('(' term (',' term)* ')')?							# AppPred
	| '\\old' '(' pred ')'										# OldPred
	| '(' pred ')'												# ParPred
	| pred '&&' pred											# ConPred
	| pred '||' pred											# DisPred
	| pred '==>' pred											# ImpPred
	| pred '<==>' pred											# EquPred
	| '!' pred													# NegPred
	| pred '^^' pred											# XorPred
	| ('\\forall' | '\\exists') binder (',' binder)* ';' pred	# QuantiPred;

binder: ('boolean' | 'integer' | 'real') IDENT;

funcContract:
	'/*@' requiresClause* decreasesClause? ensuresClause* '*/'
	| '//@' requiresClause* decreasesClause? ensuresClause* LINEEND
	;

requiresClause: 'requires' pred ';';

decreasesClause: 'decreases' term ';';

ensuresClause: 'ensures' pred ';';

assertion:
	'/*@' 'assert' pred ';' '*/'
	| '//@' 'assert' pred ';' LINEEND
	;

loopAnnot:
	'/*@' ('loop' 'invariant' pred ';')* (
		'loop' 'variant' term ';'
	)? '*/'
	| '//@' ('loop' 'invariant' pred ';')* ('loop' 'variant' term ';')? LINEEND
	;

predDef:
	'/*@' 'predicate' IDENT ('(' para (',' para)* ')')? '=' pred ';' '*/'
	| '//@' ('loop' 'invariant' pred ';')* ('loop' 'variant' term ';')? LINEEND
	;

/* miscellaneous */
constant: INT_CONSTANT | FLOAT_CONSTANT | 'true' | 'false';
