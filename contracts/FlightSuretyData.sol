pragma solidity ^0.4.25;
////*
//passengers pay up to 1 ether
///flight numbers and timestamps are fixed for this project
//if there is a delay they get 1.5x times the amount they paid
//the passenger doesn't get the funds directly to there wallet, there is a balence then they have to tkae it directly from the wallet
//^makes ure ther eis saftey shit in here

import "../node_modules/openzeppelin-solidity/contracts/math/SafeMath.sol";

contract FlightSuretyData {
    using SafeMath for uint256;

    /********************************************************************************************/
    /*                                       DATA VARIABLES                                     */
    /********************************************************************************************/

    address private contractOwner;                                      // Account used to deploy contract
    bool private operational = true;                                    // Blocks all state changes throughout the contract if false
    

    

    struct Flights {
        bool isRegistered;
        address airline;
        string flightNum;
        string departureCity;

        uint64 departureTime;
    }
 
    struct Airlines{
        address airline;
        bool isRegistered;
        bool isFunded;
        uint funds;
    }

   /* struct PassAmtPaid{
        address[] passenger;
        uint[] amountPaid;
    } */
    uint64 totalAprovedAirlines;
    mapping(address => address[]) approvalRouting; //1st address, address of the airliens, the second is the list of petitioning airlines
    mapping(address => Airlines) airlines; // Approved Airlines 

    mapping(string => Flights) flights; //uint will equal the flightNum
    mapping(string => address[]) customers;
    mapping(bytes32 => uint) InsuranceLedger; //bytes is both thepassenger and flights concatenated together; instead of having 3 varaislbe
    //we push the two variables together

    mapping(address => uint256) owedMoney;
            
   


    /********************************************************************************************/
    /*                                       EVENT DEFINITIONS                                  */
    /********************************************************************************************/
//EVENTS


    event AirlinesRegistered (address indexed airlineregis);
    event FlightRegistered (address indexed flightregis);
    event PassCredited (address indexed pass, uint256 value);

   

    /**
    * @dev Constructor
    *      The deploying account becomes contractOwner
    */

    constructor
                                (
                                ) 
                                public 
    {
        contractOwner = msg.sender;
        totalAprovedAirlines =1;
            airlines[contractOwner].airline = contractOwner;
            airlines[contractOwner].isRegistered = true;
            airlines[contractOwner].isFunded =true;
            approvalRouting[contractOwner].push(contractOwner);
    

           //Need to authorized a caller but the sequence is off authorizeCaller(contractOwner);
    }

    /********************************************************************************************/
    /*                                       FUNCTION MODIFIERS                                 */
    /********************************************************************************************/

    // Modifiers help avoid duplication of code. They are typically used to validate something
    // before a function is allowed to be executed.

/*
    * @dev Modifier that requires the "operational" boolean variable to be "true"
    *      This is used on all state changing functions to pause the contract in 
    *      the event there is an issue that needs to be fixed
    */
   
    modifier requireIsOperational() 
    {
        require(operational, "Contract is currently not operational");
        _;  // All modifiers require an "_" which indicates where the function body will be added
    }

    /**
    * @dev Modifier that requires the "ContractOwner" account to be the function caller
   */
    modifier requireContractOwner()
    {
        require(msg.sender == contractOwner, "Caller is not contract owner");
        _;
    }
/*
    modifier requireAuthorizedCallers(){
        require(authCallers[msg.sender]== true, "Caller not authorized" );
        _;
    }
*/
    /********************************************************************************************/
    /*                                       UTILITY FUNCTIONS                                  */
    /********************************************************************************************/

    /**
    * @dev Get operating status of contract
    *
    * @return A bool that is the current operating status
    */      
    function isOperational() 
                            public 
                            view 
                            returns(bool) 
    {
        return operational;
    }


    /**
    * @dev Sets contract operations on/off
    *
    * When operational mode is disabled, all write transactions except for this one will fail
    */    
    function setOperatingStatus
                            ( bool mode) 
                            external 
                            returns(bool)
    {

        operational = mode;
        return mode;
    }

    /********************************************************************************************/
    /*                                     SMART CONTRACT FUNCTIONS                             */
    /********************************************************************************************/
  //function caollasp end }

///putting in Authorized Caller
    function authorizeCaller(address _address) external{
         //appAirlines[_address] = true;
    } 
   /**
    * @dev Add an airline to the registration queue
    *      Can only be called from FlightSuretyApp contract
    *
    */   

    function getContractOwnerAddress () view returns(address){
        return contractOwner;
    }


 function registerAirline
                            (address air, address sender)                            
                            external returns(bool)
                            
    {
       require(!airlines[air].isRegistered, "Airlines is  registered"); //undefined! equal false 
       require(airlines[sender].isFunded, "Sender not funded"); //need to constrain who calls it
       
            if(totalAprovedAirlines < 2){ //set to 2 for easy testing purposes
                                        
                        airlines[air].airline = air;
                        airlines[air].isRegistered = true;
                        airlines[air].isFunded = false;
                      
                        totalAprovedAirlines = totalAprovedAirlines+1;
                        approvalRouting[air].push(sender);
                        emit AirlinesRegistered(sender);
                     
                        return true;
               
                
            }else {
                bool isDuplicate =false; 
                uint x;
                for(x =0; x <approvalRouting[air].length; x++ ){
                    if(approvalRouting[air][x] == sender){
                        isDuplicate = true;
                    }
                }
                require(isDuplicate == false, "Duplicate call by airlines");

                if(approvalRouting[air].length > (totalAprovedAirlines/2) ){
                        airlines[air].airline = air;
                        airlines[air].isRegistered = true;
                        airlines[air].isFunded = false;
                      
                        totalAprovedAirlines = totalAprovedAirlines+1;
                        approvalRouting[air].push(sender);
                        emit AirlinesRegistered(sender);
                     
                        return true;
                } else {
                     approvalRouting[air].push(sender);
                }
            
                    return false; }

    }
    
    function getregisteredAirline(address air)external returns (address) {
        
       address results = airlines[air].airline;
        return results;

    }
    
    function registerFlight(address air, string flightNum, string departureCity, uint64 departureTime)

    external returns(bool){
        require(airlines[air].isRegistered, "Airlines not registered");
  
   flights[flightNum].isRegistered =true;
   flights[flightNum].airline = air;
   flights[flightNum].flightNum = flightNum;
   flights[flightNum].departureCity = departureCity;
   flights[flightNum].departureTime = departureTime;
  
  emit FlightRegistered(air);
    return true;

    }

    function getFlight(string flightNum) view returns(string){
        return flights[flightNum].departureCity;
    }
   /**
    * @dev Buy insurance for a flight
    *
    */   
    function buy
                            (string flightNum, address passenger, uint value                 
                            )
                            external
                            payable returns(bool)
    {
    require(flights[flightNum].isRegistered, "Flight not registered");
    bytes32 passFlight = keccak256(abi.encodePacked(passenger, flightNum));
    require(InsuranceLedger[passFlight] == uint(0), "Already bought insureance");
    require(value <= 1, "Can only pay up to 1 ether for insurance" );
    //add flightNum & passender value
 
        
        InsuranceLedger[passFlight]=value; 
        return true;
     
    }

    
   

    /**
     *  @dev Credits payouts to insurees
    */
    function creditInsurees(string flightNum, address passenger
                                )
                                external
                                payable
    {
      
        bytes32 passFlight = keccak256(abi.encodePacked(passenger, flightNum));
        require(InsuranceLedger[passFlight] != uint(0), "No insureance bought");
       owedMoney[passenger] =  owedMoney[passenger] + (InsuranceLedger[passFlight]*2);//change to 1.5 later 
    }

    function getAmountCredited (string flighNum, address passenger) external returns (uint256){

        uint256 results = owedMoney[passenger];
        return results;
    }
     
    /**
     *  @dev Transfers eligible payout funds to insuree
     *
    */
    function pay
                            (uint256 monies, address passenger
                            )
                            external
                            payable
    {
    
        require(msg.sender == passenger, "Not senders funds");
        require(( owedMoney[passenger]-monies) >= 0, "Insufficent monies to pay insurance");
    
        owedMoney[passenger]= owedMoney[passenger]-monies;

        msg.sender.transfer(monies);
        
        emit PassCredited(passenger, monies);
    }
  
    
    



   /**
    * @dev Initial funding for the insurance. Unless there are too many delayed flights
    *      resulting in insurance payouts, the contract should be self-sustaining
    *
    */   
    function fund
                            (uint amount, address airlinesAddress, address petitioner
                            )
                            public
                            payable returns(bool)
    {
        require(airlines[petitioner].isRegistered == true, "Unregisterd airlines cannot fund" );

      //  approvedAirlines[airlinesAddress].funds = approvedAirlines[airlinesAddress].funds+amount; 
        airlines[airlinesAddress].isFunded = true;
        return true;
    }



    function isAirline(address airlineAddress) public returns(bool){
    
    return airlines[airlineAddress].isRegistered;
    }

    function getFlightKey
                        (
                            address airline,
                            string memory flight,
                            uint256 timestamp
                        )
                        pure
                        internal
                        returns(bytes32) 
    {
        return keccak256(abi.encodePacked(airline, flight, timestamp));
    }

    /**
    * @dev Fallback function for funding smart contract.
    *
    */
    function() 
                            external 
                            payable 
    {
        fund(3, msg.sender, msg.sender);
    }


}

