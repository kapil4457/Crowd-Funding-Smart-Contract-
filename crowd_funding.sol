//SPDX-License-Identifier : UNLICENSED

pragma solidity >=0.5.0 < 0.9.0;

contract CrowdFunding{

    mapping(address=>uint) public contributors;
    address public manager;
    uint public minimumContribution;
    uint public deadline;
    uint public target;
    uint public raisedAmount;
    uint public noOfContributors;


        struct request{
            string description;
            address payable recepient;
            uint value;
            bool completed;
            uint noOfVoters;
            mapping(address=>bool) voters;
        }
        mapping(uint=>request) public requests;
        uint public numRequests;

     constructor(uint _target , uint _deadline) public{
        manager = msg.sender;
        target = _target;
        deadline = block.timestamp+ _deadline;
        minimumContribution =100 wei;
        }


        //Sending wei to contract
        function sendEth() public payable{
            require(block.timestamp < deadline , "DeadLine Has passed");
            require(msg.value>=minimumContribution , "Minimum Contribution need to be atleast 100 wei");

            if(contributors[msg.sender]==0){
                noOfContributors++;
            }

            contributors[msg.sender]+=msg.value;
            raisedAmount += msg.value;

        }

        function getContractBalance() public view returns(uint){
            return address(this).balance; 
        }


        
        function refund()public payable {
                require(block.timestamp > deadline  && raisedAmount!=target , "You are not eligible for the refund");
                require(contributors[msg.sender] > 0 , "You have not contributed yet");

                address payable user = payable(msg.sender);

                user.transfer(contributors[msg.sender]);
                contributors[msg.sender] = 0;
        }

        //Modifier are the reusable peice of code in the file
        modifier onlyManager(){
         require(msg.sender == manager , "Only manager can call this function.");
         _;
        }


        function createRequest(string memory _descriptions , address payable _receipient , uint _value) public payable onlyManager{
        request storage r = requests[numRequests];
        numRequests++;
        r.description = _descriptions;
        r.recepient = _receipient;
        r.value = _value;
        r.completed = false;
        r.noOfVoters = 0;
        }


        function voteRequest(uint reqNo) public{
            require(contributors[msg.sender] > 0  , "You must be a contributor");
            request storage thisRequest = requests[reqNo];
            require(thisRequest.voters[msg.sender]==true , "You have already voted");
            thisRequest.voters[msg.sender] = true;
            thisRequest.noOfVoters ++;

        }

        function transferFund(uint reqNo) public payable onlyManager{
                require(raisedAmount >= target);
                request storage thisRequest = requests[reqNo];
                require(thisRequest.completed==false , "This requst has been completed");
                require(thisRequest.noOfVoters > noOfContributors/2 , "Majority does not support");

                thisRequest.recepient.transfer(thisRequest.value);
                thisRequest.completed=true;

        }

        
        


}