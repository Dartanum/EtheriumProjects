pragma solidity >=0.4.22 <0.9.0;

contract Bank {

   struct Credit {
      uint16 percentageRate;
      uint currentSum ;
      uint months;
   }
   struct Client {
      address id;
      bytes login;
      bytes password;
      int balance;
      Credit credit;
   }
   uint private Storage;
   uint private numberClient;
   address private owner;
   Client[] private clients;

   constructor () public {
      //clients = new Client[](10);
      Storage = 100;
      owner = msg.sender;
      numberClient = 0;
   }

   modifier checkOwner() {
      require(msg.sender == owner);
      _;
   }

   event RegisterError(address id, bytes message);

   function register(bytes memory login, bytes memory password) public { //clear func
      bytes memory error = "This login already exist";
      bool isExist = false;
      Client memory temp;
      Client memory newClient = Client(msg.sender, login, password, 0, Credit(0, 0, 0));
      for(uint i = 0; i < numberClient; i++) {
         temp = clients[i];
         require(temp.id != msg.sender);
         if(keccak256(temp.login) == keccak256(newClient.login)) {
            emit RegisterError(msg.sender, error);
            isExist = true;
            break;
         }
      }
      if(!isExist) {
         clients.push(newClient);
         numberClient++;
      }
   }

   function takeCredit(uint16 percent, uint sum, uint month) public {
      Client memory temp;
      for(uint i = 0; i < numberClient; i++) {
         temp = clients[i];
         if(temp.id == msg.sender) {
            clients[i] = Client(temp.id, temp.login, temp.password, temp.balance, Credit(percent, sum, month));
            break;
         }
      }
   }

   function checkClientsEqual() private view returns(bool) { //view function (doesn't edit storage variable)

   }

   function pureFunction() private pure returns(int) { //pure function (doesn't read storage variable)

   }

   function getStorage() public view checkOwner returns(uint) {
      return Storage;
   }
}