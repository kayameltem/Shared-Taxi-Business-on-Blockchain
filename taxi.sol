// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

contract TaxiInvestment{

    address payable public owner;

    // maps the address of each participants to the participant struct.
    mapping(address => Participant) private participants ;

    // holds the address of each participants
    address[] private participants_arr;

    // Taxi driver
    Driver private driver;

    // ID of car dealer
    address payable private carDealer;

    // The total money has not been distributed yet.
    uint private contractBalance;

    // The total amount for maintenance and tax is fixed as 10 Ether/6months
    uint private constant fixedExpenses = 10 ether;

    // An amount that participants needs to pay for entering the taxi business
    // The amount is fixed as 100 Ether
    uint private constant participationFee = 10 ether;

    // CarID, identifies owned car with a 32 digit number
    uint32 private carID;

    // Car proposal proposed by the CarDealer
    CarProposal private proposedCar;

    // Car repurchase proposal proposed by the CarDealer
    CarProposal private proposedRepurchase;

    // Driver proposed by participants
    Driver private proposedDriver;

    //Last divinded date
    uint256 private lastDivindedDate;

    //last car expenses payement date
    uint256 private lastCarExpensesDate;

    event LogGetCharge(address customer, uint amount);




    //struct of Participants holds required variables 
    struct Participant {

        // is valid, indicates whether participant exists.
        bool isValid;

        uint balance;

        // voting variables, default is false.
        bool carVote;
        bool repurchaseVote;
        bool driverVote;
        bool fireVote;
    } 
    

    // struct of Driver holds required variables
    struct Driver {
        address payable addr;
        uint salary;
        bool isProposed;
        uint approvalState;
        uint256 lastSalaryDate;
    }

    // struct of CarProposal holds required variables
    struct CarProposal {
        uint32 ID;
        uint price;
        uint256 validTime; 
        uint approvalState;
   

    }

    // ****** M O D I F I E R S ******

    // modifier -> if caller is the owner
    modifier isOwner() {
        require(msg.sender == owner, "Owner is expected");
        _;
    }


    // modifier -> if caller is a car dealer
    modifier isCarDealer() {
        require(msg.sender == carDealer, "Car dealer is expected");
        _;
    }

    // modifier -> if caller is a driver
    modifier isDriver() {
        require(msg.sender == driver.addr, "Driver is expected");
        _;
    }

    // modifier -> if caller is a participant
    modifier isParticipant() {
        require(participants[msg.sender].isValid, "Participant is expected");
        _;
    }


    // ****** F U N C T I O N S ******

    // sets initial values for state variables
    constructor(address payable _carDealer) {
        
        owner = payable(msg.sender);
        carDealer = _carDealer;
        contractBalance = 0;

        // set variables to current time
        lastDivindedDate = block.timestamp;
        lastCarExpensesDate = block.timestamp;
    }

    // Call the join function when someone wants to be a participant of the taxi investment
    function join() public payable {
        require(participants_arr.length < 9, "The participation capacity is full.");
        require(!participants[msg.sender].isValid, "The participant has already existed.");
        require(msg.value == participationFee, "Participation Fee is 100 ether to join.");

        // pay the participation fee
        contractBalance += participationFee;
        if(!owner.send(participationFee)){
            contractBalance -= participationFee;
            revert("An error occured while sending the money");
        } 
        // be a participant of the taxi investment
        participants_arr.push(msg.sender);
        participants[msg.sender] = Participant(true,0 ether,false,false,false,false);
    
    }

    // set the values of proposedCar
    function carProposeToBusiness(uint32 _carID, uint _price, uint _validTime) public isCarDealer {
        proposedCar = CarProposal(_carID,_price,_validTime,0);

        // reset carVote of each Participants
        for (uint i = 0; i < participants_arr.length; i++) {
            participants[participants_arr[i]].carVote = false;
        }

    }

    // approves the Proposed Purchase with incrementing the approval state
    function approvePurchaseCar() public isParticipant {
            
        require(!participants[msg.sender].carVote, "You have already voted");
        proposedCar.approvalState += 1;
        participants[msg.sender].carVote = true;

        if (proposedCar.approvalState > participants_arr.length / 2){
            purchaseCar();
        }
        

    }

    //Sends the CarDealer the price of the proposed car if the offer is still valid
    function purchaseCar() public {
        require(proposedCar.validTime >= block.timestamp, "The valid offer time has been expired");
        require(contractBalance >= proposedCar.price, "No enough money");

        // ensure whether the money has been sent.
        contractBalance -= proposedCar.price;
        if(!carDealer.send(proposedCar.price)){
            contractBalance += proposedCar.price;
            revert("An error occured while sending the money");
        }
        carID = proposedCar.ID;
        
    }

    // sets proposed purchase values
    function repurchaseCarPropose(uint _price, uint _validTime) public isCarDealer {
        proposedRepurchase = CarProposal(carID, _price, _validTime, 0);

        // reset repurchaseVote of each Participants
        for (uint i = 0; i < participants_arr.length; i++) {
            participants[participants_arr[i]].repurchaseVote = false;
        }
        
    }

    //approves the Proposed Sell with incrementing the approval state
    function approveSellProposal() public isParticipant {
        require(!participants[msg.sender].repurchaseVote, "You have already voted");
        participants[msg.sender].repurchaseVote = true;
        proposedRepurchase.approvalState += 1;

        //when the majority of participants approve, calls Repurchasecar function
        if (proposedRepurchase.approvalState > participants_arr.length / 2){
            repurchaseCar();
        }
        
    }

    //sends the proposed car price to contract if the offer is still valid
    function repurchaseCar() public payable {
        
        require(proposedRepurchase.validTime >= block.timestamp, "The offer time has been expired");

        contractBalance += proposedRepurchase.price;
        if(!payable(owner).send(proposedRepurchase.price)){
            contractBalance -= proposedRepurchase.price;
            revert("An error occured while sending the money");
        }
        //reset carID and proposedCar
        carID = 0;
        delete proposedCar;
    }

    // caller propose itself as a driver and sets its values
    function ProposeDriver(address payable _addr, uint _salary) public {
        require(!proposedDriver.isProposed, ". Only one proposed driver can be set");
        //temporary driver object for voting
        proposedDriver = Driver(_addr, _salary, true, 0, 0);

        // reset driverVote of each Participants
        for (uint i = 0; i < participants_arr.length; i++) {
            participants[participants_arr[i]].driverVote = false;
        }

    }

    //approves the Proposed Driver with incrementing the approval state
    function approveDriver() public isParticipant {
        require(!participants[msg.sender].driverVote, "You have already voted");
        participants[msg.sender].driverVote = true;
        proposedDriver.approvalState += 1;

        //When the majority of participants approve, calls SetDriver function
        if (proposedDriver.approvalState > participants_arr.length / 2){
            setDriver();

        }
        
    }
    
    //sets the Driver info
    function setDriver() public {
        require(!driver.isProposed, ". Only one driver can be set");
        driver = Driver(proposedDriver.addr, proposedDriver.salary, true, 0, block.timestamp);
        //clears proposed driver info
        delete proposedDriver;
    }

    //approves firing driver with incrementing the approval state
    function proposeFireDriver() public isParticipant {
        require(driver.isProposed, "There is no taxi driver");
        require(!participants[msg.sender].fireVote, "You have already voted");
        participants[msg.sender].fireVote = true;
        driver.approvalState += 1;
        //When the majority of participants approve, calls Fire Driver function
        if (driver.approvalState > participants_arr.length / 2){
            fireDriver();
        }
    
    }

    //sends any amount of money of the current driver address
    function fireDriver() public {
        
        contractBalance -= driver.salary / 2 ;
        if(!driver.addr.send(driver.salary /2)) {
            contractBalance += driver.salary / 2 ;
            revert();
        }
        //clear driver info
        delete driver;

    }

    //driver leaves job 
    function leaveJob() public isDriver {
        fireDriver();
    }

    //customers who use the taxi pays their ticket to the contract
    function getCharge() public payable {
        contractBalance += msg.value;
        emit LogGetCharge(msg.sender, msg.value);

    }

    // releases the salary of the Driver monthly.
    //This function can be called per month once at most
    function getSalary() public payable isDriver {
        require(driver.isProposed, "There is no taxi driver");
        require(block.timestamp - driver.lastSalaryDate >= 30 days, "Driver has already gotten the salary of this month.");
        uint totalSalary = driver.salary * ((block.timestamp - driver.lastSalaryDate) / 30 days);
        require(totalSalary > 0, "No money has been earned this month.");
        contractBalance -= totalSalary;
        if(!driver.addr.send(totalSalary)) {
            contractBalance += totalSalary;
            revert("An error occured while sending the money");
        }
        driver.lastSalaryDate = block.timestamp;

    }

    //sends the CarDealer the price of the expenses every 6 month once at most.   
    function carExpenses() public isParticipant {
        require(block.timestamp - lastCarExpensesDate >= 180 days, "It has been less than 6 months");
        require(contractBalance >= fixedExpenses,"The contract balance is less than car expenses");
        require(carID != 0, "There is no car");

        contractBalance -= fixedExpenses;
        if(!carDealer.send(fixedExpenses)){
            contractBalance += fixedExpenses;
            revert("An error occured while sending the money");
        }
        lastCarExpensesDate = block.timestamp;
    }

    //calculates the profit per participant and releases this amount to participants in every 6 month once at most.
    function payDividend() public isParticipant {
        require(block.timestamp - lastDivindedDate >= 180 days, "It has been less than 6 months");

        if(block.timestamp - lastCarExpensesDate >= 180 days){ 
            contractBalance -= fixedExpenses;
            if(!carDealer.send(fixedExpenses)){
                contractBalance += fixedExpenses;
                revert("An error occured while sending the money");
            }   
            lastCarExpensesDate = block.timestamp;
        }     

        if(block.timestamp - driver.lastSalaryDate >= 30 days) {
            uint totalSalary = driver.salary * ((block.timestamp - driver.lastSalaryDate) / 30 days);
            contractBalance -= totalSalary;
            if(!driver.addr.send(totalSalary)) {
                contractBalance += totalSalary;
                revert("An error occured while sending the money");
            }
            driver.lastSalaryDate = block.timestamp;
        }

        for (uint i= 0; i < participants_arr.length; i++){
            participants[participants_arr[i]].balance += contractBalance / participants_arr.length;
        }
        contractBalance = 0;
        lastDivindedDate = block.timestamp;

    }

    // sends the money of the participant to her/him account.
    function getDividend() public payable isParticipant {
        if(participants[msg.sender].balance > 0) {       
            if(!payable(msg.sender).send(participants[msg.sender].balance)){
                revert("An error occured while sending the money");
            }
            participants[msg.sender].balance = 0;
        }
    }

    // fallback function
	fallback () external {
		revert(); 
	}
}