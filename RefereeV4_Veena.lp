%------------------------------------------------------------------------------------------------------------------------------
%Generate Search space
%------------------------------------------------------------------------------------------------------------------------------
{assign(C,R) : referee(R,RTYPE,MAXWORK,PREVWORK,PREVPAY)}=1  :- case(C,CTYPE,EFFORT,DAMAGE,POST,PAY).

%------------------------------------------------------------------------------------------------------------------------------
%Hard constraints
%------------------------------------------------------------------------------------------------------------------------------
%weed out all the assignemnets where prefType is 0
:- assign(C,R),referee(R,RTYPE,MAXWORK,PREVWORK,PREVPAY),case(C,CTYPE,EFFORT,DAMAGE,POST,PAY), prefType(R,CTYPE,0).
%------------------------------------------------------------------------------------------------------------------------------
%weed out all the assignemnets where prefRegion is 0
:- assign(C,R),referee(R,RTYPE,MAXWORK,PREVWORK,PREVPAY),case(C,CTYPE,EFFORT,DAMAGE,POST,PAY), prefRegion(R,POST,0).
%------------------------------------------------------------------------------------------------------------------------------
% weed out the cases where external referees are assigned workload more than threshold
:- assign(C,R),referee(R,RTYPE,MAXWORK,PREVWORK,PREVPAY),case(C,CTYPE,EFFORT,DAMAGE,POST,PAY), 
RTYPE==e,externalMaxDamage(D), D<DAMAGE.
%------------------------------------------------------------------------------------------------------------------------------
% weed out the cases where actual work load is greater than max working minutes - this works fine, no doubt
:-S = #sum{EFFORT,R,C : assign(C,R),case(C,CTYPE,EFFORT,DAMAGE,POST,PAY)},referee(R,RTYPE,MAXWORK,PREVWORK,PREVPAY), S>MAXWORK.

%------------------------------------------------------------------------------------------------------------------------------
%weak constraints
%------------------------------------------------------------------------------------------------------------------------------

%Overall payment of external referees is similar
pay(R,W) :-  W =  #sum{PAY,R,C:assign(C,R),case(C,CTYPE,EFFORT,DAMAGE,POST,PAY)},referee(R,RTYPE1,MAXWORK,PREVWORK1,PREVPAY), RTYPE1==e.

minpay(PREVPAY1) :- referee(R1,RTYPE1,MAXWORK1,PREVWORK1,PREVPAY1), RTYPE1==e, 0==#count{1,R2 : PREVPAY1>PREVPAY2,referee(R2,RTYPE2,MAXWORK2,PREVWORK2,PREVPAY2), RTYPE2==e },referee(R1,RTYPE1,MAXWORK1,PREVWORK1,PREVPAY1), RTYPE1==e.

maxpay(PREVPAY1) :- referee(R1,RTYPE1,MAXWORK1,PREVWORK1,PREVPAY1), RTYPE1==e, 0==#count{1,R2 : PREVPAY1<PREVPAY2,referee(R2,RTYPE2,MAXWORK2,PREVWORK2,PREVPAY2) , RTYPE2==e },referee(R1,RTYPE1,MAXWORK1,PREVWORK1,PREVPAY1), RTYPE1==e.

%#show minpay/1.
%#show maxpay/1.

initialpaydiff(D) :- D = (MAX-MIN), maxpay(MAX), minpay(MIN).
%#show initialpaydiff/1.

totalpay(R,W2) :- W2=PREVPAY+W, referee(R,RTYPE1,MAXWORK,PREVWORK1,PREVPAY), pay(R,W), RTYPE1==e.
%#show totalpay/2.

minpayafter(W1) :- totalpay(R1,W1), 0==#count{1,R2 : W1>W2,totalpay(R2,W2) },totalpay(R1,W1).

maxpayafter(W1) :- totalpay(R1,W1), 0==#count{1,R2 : W1<W2,totalpay(R2,W2) },totalpay(R1,W1).

%:~ totalpay(R,S). [S*10]
%#minimize{D: totalpay(R,D)}.


%#show minpayafter/1.
%#show maxpayafter/1.

finalpaydiff(D) :- D = (MAX-MIN), maxpayafter(MAX), minpayafter(MIN).
%#show finalpaydiff/1.

%Minimize such that the assignemnt with least finalpaydiff is selected
#minimize{D,C,R:finalpaydiff(D),assign(C,R),referee(R,RTYPE,MAXWORK,PREVWORK,PREVPAY),case(C,CTYPE,EFFORT,DAMAGE,POST,PAY) }.
%----------------------------------------------------------------------------------------------------------------------------------------------------------
%The assignment of cases to referees should be fair in the sense that their overall workload should be balanced.
%Final min-max differnece should be <= initial min-max difference.

%Total work of referees based on cases assigned.
work(R,W) :-  W =  #sum{EFFORT,R,C:assign(C,R),case(C,CTYPE,EFFORT,DAMAGE,POST,PAY)},referee(R,RTYPE1,MAXWORK,PREVWORK1,PREVPAY).

minwork(PREVWORK1) :- referee(R1,RTYPE1,MAXWORK1,PREVWORK1,PREVPAY1), 0==#count{1,R2 : PREVWORK1>PREVWORK2,referee(R2,RTYPE2,MAXWORK2,PREVWORK2,PREVPAY2) },referee(R1,RTYPE1,MAXWORK1,PREVWORK1,PREVPAY1).

maxwork(PREVWORK1) :- referee(R1,RTYPE1,MAXWORK1,PREVWORK1,PREVPAY1), 0==#count{1,R2 : PREVWORK1<PREVWORK2,referee(R2,RTYPE2,MAXWORK2,PREVWORK2,PREVPAY2) },referee(R1,RTYPE1,MAXWORK1,PREVWORK1,PREVPAY1).

%#show minwork/1.
%#show maxwork/1.

initialworkdiff(D) :- D = (MAX-MIN), maxwork(MAX), minwork(MIN).
%#show initialworkdiff/1.

%Total workload of all Referees with previous work included.
totalworkload(R,W2) :- W2=PREVWORK1+W, referee(R,RTYPE1,MAXWORK,PREVWORK1,PREVPAY), work(R,W).

minworkafter(W1) :- totalworkload(R1,W1), 0==#count{1,R2 : W1>W2,totalworkload(R2,W2) },totalworkload(R1,W1).

maxworkafter(W1) :- totalworkload(R1,W1), 0==#count{1,R2 : W1<W2,totalworkload(R2,W2) },totalworkload(R1,W1).

%#show minworkafter/1.
%#show maxworkafter/1.

finalworkdiff(D) :- D = (MAX-MIN), maxworkafter(MAX), minworkafter(MIN).
%#show finalworkdiff/1.

%Final min-max differnece should be <= initial min-max difference.
%:- assign(C1,R1),assign(C2,R2),R1!=R2,initialworkdiff(D1),finalworkdiff(D2),D2>D1.

%Minimize such that the assignemnt with least finalworkdiff is selected
#minimize{D,C,R:finalworkdiff(D),assign(C,R),referee(R,RTYPE,MAXWORK,PREVWORK,PREVPAY),case(C,CTYPE,EFFORT,DAMAGE,POST,PAY) }.

%#show totalworkload/2.

%----------------------------------------------------------------------------------------------------------------------------------------------------------

% internal referees are preferred over external referees
extnumber(D) :- D=#count{1,R : assign(C,R),referee(R,RTYPE1,MAXWORK,PREVWORK1,PREVPAY),RTYPE1==e }.
intnumber(D) :- D=#count{1,R : assign(C,R),referee(R,RTYPE1,MAXWORK,PREVWORK1,PREVPAY),RTYPE1==i }.
#maximize{D: intnumber(D)}.

%#show extnumber/1.
%#show intnumber/1.
%----------------------------------------------------------------------------------------------------------------------------------------------------------

%Referees should handle cases in regions with higher preference and handle types of cases with higher preference.
#maximize{PREF1+PREF2,R: assign(C,R), referee(R,RTYPE,MAXWORK,PREVWORK,PREVPAY),case(C,CTYPE,EFFORT,DAMAGE,POST,PAY), prefRegion(R,POST,PREF1),prefType(R,CTYPE,PREF2)}.

%----------------------------------------------------------------------------------------------------------------------------------------------------------

#show assign/2.