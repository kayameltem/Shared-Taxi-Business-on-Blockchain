# Shared-Taxi-Business-on-Blockchain
Imagine a group of people in the same neighborhood who would like to invest into an asset. A smart contract that handles a common asset and distribution of income generated from this asset in certain time intervals. The common asset in this scenario is a taxi. </br>

In this project you are asked to create a smart contract that handles a common asset and distribution of income
generated from this asset in certain time intervals. The common asset in this scenario is a taxi.
Imagine a group of people in the same neighborhood who would like to invest into an asset. They cannot invest
individually because each person has a very small amount of money, thus they can combine their holdings together
to invest into a bigger and more profitable investment.
They decided to combine their money and buy a car which will be used as a taxi and the profit will be shared
among participants every month. However, one problem is that they have no trust in each other.
To make this investment work, you are asked to write a smart contract that will handle the transactions. The
contract will run on Ethereum network.</br>

To make this investment work, you are asked to write a smart contract that will handle the transactions. The
contract will run on Ethereum network.</br>

The contract should **at least include** below. If you need to extend the state variables and functions, you are free to
do so as long as they are necessary. For function parameters try to write functions as few parameters as possible,
none preferred if possible.</br>
For the functions that send and receive money, like join, purchasecar, sellcar, getchargei getsalary, carexpenses,
getdividend should send/transfer the amount to the address that it supposed to. you can keep a mapping for the
balance for individuals, and update the balances internally but when above functions called, you need to actually
send/receive money (ether/wei).</br>

Keep a contract balance.</br>
### State Variables: 
&nbsp;&nbsp;&nbsp;&nbsp;**Participants:** maximum of 9, each participant identified with an address and has a balance
</br>
&nbsp;&nbsp;&nbsp;&nbsp; **Taxi Driver:** 1 taxi driver and salary
</br>
&nbsp;&nbsp;&nbsp;&nbsp; **Car Dealer:** An identity to buy/sell car, also handles maintenance and tax
</br>
&nbsp;&nbsp;&nbsp;&nbsp; **Contract balance:** Current total money in the contract that has not been distributed
</br>
&nbsp;&nbsp;&nbsp;&nbsp; **Fixed expenses:** Every 6 months car needs to go to Car Dealer for maintenance and taxes needs to be
paid, total amount for maintenance and tax is fixed and 10 Ether for every 6 months.
</br>
&nbsp;&nbsp;&nbsp;&nbsp;**Participation fee:** An amount that participants needs to pay for entering the taxi business, it is fixed and
100 Ether
</br>
&nbsp;&nbsp;&nbsp;&nbsp; **Owned Car:** identified with a 32 digit number, CarID
</br>
&nbsp;&nbsp;&nbsp;&nbsp; **Proposed Car:** Car proposal proposed by the CarDealer, Holds {CarID, price, offer valid time and approval
state } information.
</br>
&nbsp;&nbsp;&nbsp;&nbsp; **Proposed Repurchase:** Car repurchase proposal proposed by the CarDealer, Holds {CarID (the owned
car id), price, offer valid time, and approval state} information.
</br>
&nbsp;&nbsp;&nbsp;&nbsp; **Time handles** 
</br>
### Functions: 
&nbsp;&nbsp;&nbsp;&nbsp; **Constructor:** </br>
Called by owner of the contract and sets initial values for state variables (like CarDealer)
</br>
&nbsp;&nbsp;&nbsp;&nbsp; **Join function:** </br>
Public, Called by participants, Participants needs to pay the participation fee set in the contract to be a
member in the taxi investment
</br>
&nbsp;&nbsp;&nbsp;&nbsp; **CarProposeToBusiness:** </br>
Only CarDealer can call this, sets Proposed Car values, such as CarID, price, offer valid time and
approval state (to 0)
</br>
&nbsp;&nbsp;&nbsp;&nbsp; **ApprovePurchaseCar:** </br>
Participants can call this function, approves the Proposed Purchase with incrementing the approval
state. Each participant can increment once. When the majority of participants approve, calls PurschaseCar
function
</br>
&nbsp;&nbsp;&nbsp;&nbsp; **PurchaseCar:** </br>
Sends the CarDealer the price of the proposed car if the offer valid time is not passed yet
</br>
&nbsp;&nbsp;&nbsp;&nbsp; **RepurchaseCarPropose:** </br>
Only CarDealer can call this, sets Proposed Purchase values, such as CarID, price, offer valid time and
approval state (to 0)
</br>
&nbsp;&nbsp;&nbsp;&nbsp; **ApproveSellProposal:** </br>
Participants can call this function, approves the Proposed Sell with incrementing the approval state.
Each participant can increment once. When the majority of participants approve, calls Repurchasecar function
</br>
&nbsp;&nbsp;&nbsp;&nbsp; **Repurchasecar:** </br>
Sends the proposed car price to contract if the offer valid time is not passed yet
</br>
&nbsp;&nbsp;&nbsp;&nbsp; **ProposeDriver:** </br>
Caller proposes himself/herself as driver and sets his/her address, and expected salary. Only one
proposed driver can be set,
</br>
&nbsp;&nbsp;&nbsp;&nbsp; **ApproveDriver:** </br>
Participants can call this function, approves the Proposed Driver with incrementing the approval state.
Each participant can increment once. When the majority of participants approve, calls SetDriver function
</br>
&nbsp;&nbsp;&nbsp;&nbsp; **SetDriver:** </br>
Sets the Driver info if approval state is approved by more than half of the participants. Clears proposed
driver info
</br>
&nbsp;&nbsp;&nbsp;&nbsp; **ProposeFireDriver:** </br>
Participants can call this function, approves firing driver with incrementing the approval state. Each
participant can increment once. When the majority of participants approve, calls Fire Driver function
</br>
&nbsp;&nbsp;&nbsp;&nbsp; **FireDriver:** </br>
Sends any amount of money of the current driver’s account to Driver’s address. Clears the driver info
</br>
&nbsp;&nbsp;&nbsp;&nbsp; **LeaveJob:** </br>
Only Driver can call this function, calls FireDriver function
</br>
&nbsp;&nbsp;&nbsp;&nbsp; **GetCharge:** </br>
Public, customers who use the taxi pays their ticket through this function. Charge is sent to contract.
Takes no parameter. See slides 6 page 11.
</br>
&nbsp;&nbsp;&nbsp;&nbsp; **GetSalary:** </br>
Only Driver can call this function, releases the salary of the Driver to his/her account monthly. Make
sure it is not being called more than once in a month. If there is any money in Driver’s account, it will be send to
his/her address.
</br>
&nbsp;&nbsp;&nbsp;&nbsp; **CarExpenses:** </br>
Only one of the participants can initiate this function, sends the CarDealer the price of the expenses
every 6 month. Make sure it is not being called more than once in the last 6 months. 
</br>
&nbsp;&nbsp;&nbsp;&nbsp; **PayDividend:** </br>
Only one of the participants can initiate this function, calculates the total profit after expenses and
Driver salaries, calculates the profit per participant and releases this amount to participants in every 6 month.
Make sure it is not being called more than once in the last 6 months. This does NOT send money directly, but
only updates the balance on the contract and participants.
</br>
&nbsp;&nbsp;&nbsp;&nbsp; **GetDividend:** </br>
Only Participants can call this function, if there is any money in the calling participants’ account, it will
be send to his/her address.
</br>
&nbsp;&nbsp;&nbsp;&nbsp; **Fallback Function:** </br></br>
#### A note on car buying/selling process:
</br>
First dealer calls “CarProposeToBusiness”. Participants vote to approve the proposed car through
“ApprovePurchaseCar”. If the approval state is approved by more than half of the participants function calls
“PurchaseCar”.
</br></br>
To sell the car, dealer talks to people outside of the system in person. If the dealer agrees to buy the car he/she
calls the “RepurchaseCarPropose” function with intended price for the car. Participants vote to sell through
“ApproveSellProposal”. If majority approves, “Repurchasecar” is called. 
</br></br>

**Implementation:** Solidity language used on Remix to implement above functionality. 






