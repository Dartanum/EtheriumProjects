pragma solidity >=0.4.22 <0.7.0;

contract Bank {

   struct Credit {
      uint percentageRate;
      uint currentSum ;
      uint months;
   }
   struct Client {
      address payable id;
      string login;
      string password;
      uint balance;
      Credit credit;
   }
   uint private Storage;
   uint private numberClient;
   address payable private owner;
   Client[] private clients;

   constructor () public {
      Storage = 100;
      owner = msg.sender;
      numberClient = 0;
   }

   modifier checkOwner() {
      require(msg.sender == owner);
      _;
   }

   event RegisterError(address id, string message);

   event RegisterSuccess(address id, string message);

   event TakeCredit(address id, uint percent, uint sum, uint number_month);

   function register(string memory login, string memory password) public payable { //clear func
      bool isExist = false;
      Client memory temp;
      Client memory newClient = Client(msg.sender, login, password, msg.value, Credit(0, 0, 0));
      for(uint i = 0; i < numberClient; i++) {
         temp = clients[i];
         require(temp.id != msg.sender);
         if(keccak256(bytes(temp.login)) == keccak256(bytes(newClient.login))) {
            emit RegisterError(msg.sender, "This login already exist");
            isExist = true;
            break;
         }
      }
      if(!isExist) {
         emit RegisterSuccess(msg.sender, "Success register");
         clients.push(newClient);
         numberClient++;
      }
   }

   // function Login(string memory login, string memory password) public returns(Client) {
   //    Client memory temp;
   //    Client memory res;
   //    bool isFind = false;
   //    for(uint i = 0; i < numberClient; i++) {
   //       temp = clients[i];
   //       if(checkClient(temp, login, password)) {
   //          isFind = true;
   //          res = temp;
   //          break;
   //       }
   //    }
   //    return res;
   // }

   function checkClient(Client memory current, string memory login, string memory password) private pure returns(bool) {
      return (keccak256(bytes(current.login)) == keccak256(bytes(login))) && (keccak256(bytes(current.password)) == keccak256(bytes(password)));
   }
   function takeCredit(string memory login, string memory password, uint percent, uint sum, uint month) public {
      Client memory temp;
      for(uint i = 0; i < numberClient; i++) {
         temp = clients[i];
         if(checkClient(temp, login, password)) {
            clients[i] = Client(temp.id, temp.login, temp.password, temp.balance + sum, Credit(percent, sum, month));
            clients[i].id.transfer(sum);
            Storage -= sum;
            emit TakeCredit(clients[i].id, percent, sum, month);
            break;
         }
      }
   }

   function getStorage() public view checkOwner returns(uint) {
      return Storage;
   }

   function addToStorage() public payable checkOwner {
      Storage += msg.value;
   }
}