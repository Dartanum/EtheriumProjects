pragma solidity >=0.4.22 <0.9.0;

contract Bank {

   struct Credit {
      uint256 percentageRate; //процентная ставка
      uint256 currentSum; //сумма кредита
      uint256 months; //срок в месяцах
      uint256 totalSum;
   }
   struct Client {
      address payable id; //адрес клиента
      string login;
      string password;
      uint256 balance;
      Credit credit;
   }
   uint256 private Storage; //количество эфира в контракте
   uint private numberClient; //количество клиентов
   address payable private owner; //адрес владельца контракта
   Client[] private clients; //массив клиентов

   constructor () public {
      Storage = 0;
      owner = msg.sender; //msg.sender - адрес аккаунта, с которого вызывается
      numberClient = 0;
   }

   modifier checkOwner() { //модификатор (устанавливается на функцию). _; - код функции, остальное - код модификатора
      require(msg.sender == owner); //проверка, что зашел владелец контракта
      _;
   }

   event Register(address id, string message); //события (аналоги логов), вызываются в функциях с введенными параметрами

   event CreditDenied(address id, string message);

   event TakeCredit(address id, uint percent, uint sum, uint number_month);

//bank.register("test", "123", {from : accounts[1]})
   function register(string memory login, string memory password) public { //регистрация нового клиента
      bool isExist = false;
      Client memory newClient = Client(msg.sender, login, password, msg.sender.balance, Credit(0, 0, 0, 0));
      for(uint i = 0; i < numberClient; i++) { //в цикле поиск по зарегистрированным клиентам и проверка есть ли такой пользователь, который сейчас регистрируется
         require(clients[i].id != msg.sender);
         if(keccak256(bytes(clients[i].login)) == keccak256(bytes(newClient.login))) { //сравнение логинов (keccak256 - хеширование)
            emit Register(msg.sender, "This login already exist");
            isExist = true;
            break;
         }
      }
      if(!isExist) { //если такой пользователь не зарегистрирован
         emit Register(msg.sender, "Success register");
         clients.push(newClient); //добавление нового клиента в массив клиентов
         numberClient++;
      }
   }

   function checkClient(Client memory current, string memory login, string memory password) private pure returns(bool) { //pure ф-ция не использует storage переменные
      return (keccak256(bytes(current.login)) == keccak256(bytes(login))) && (keccak256(bytes(current.password)) == keccak256(bytes(password))); //сравнение логинов и паролей
   }
   //ф-ция взятия кредита
   //bank.takeCredit("test", "123", 5, web3.utils.toWei('4', 'ether'), 6, {from : accounts[1]})
   function takeCredit(string memory login, string memory password, uint256 percent, uint256 num, uint256 month) public { //percent - процентная ставка, num - сколько взял, month - на сколько
      for(uint i = 0; i < numberClient; i++) {
         if(checkClient(clients[i], login, password)) { //поиск пользователя, на которого взять кредит
            if(Storage >= num && clients[i].credit.totalSum == 0) {
               clients[i].balance += num; //добавляем сумму кредита клиенту
               clients[i].credit = Credit(percent, num, month, calculateTotalSum(percent, num, month)); //создаем кредит
               clients[i].id.transfer(num); //отправляем эфир из контракта пользователю
               Storage -= num; //уменьшаем кол-во эфира в контракте
               emit TakeCredit(msg.sender, percent, clients[i].id.balance, month);
               break;
            } else {
               emit CreditDenied(clients[i].id, "Bank cannot give you credit");
            }
         }
      }
   }
   //Ф-ция возврата кредита
   //bank.returnCredit({value : web3.utils.toWei('5', 'ether'), from : accounts[1]})
   function returnCredit() payable public {
      uint256 payment = msg.value;
      uint256 difference = 0;
      uint256 total = 0;
      for(uint i = 0; i < numberClient; i++) { //поиск нужного клиента
         if(clients[i].id == msg.sender) { 
            total = clients[i].credit.totalSum;
            if(total < payment) { //если оставшаяся сумма кредита меньше, чем платеж, то вернуть разницу отправителю
               difference = payment - total;
               clients[i].credit.totalSum = 0;
			   clients[i].balance -= total;
               msg.sender.transfer(difference);
               clients[i].credit = Credit(0, 0, 0, 0);
               Storage += total;
            }
            else {
               clients[i].credit.totalSum -= payment;
			   clients[i].balance -= payment;
            }
            break;
         }
      }
   }

   function getStorage() public view checkOwner returns(uint256) { //узнать сколько эфир в хранилище
      return Storage;
   }

   function addToStorage() public payable checkOwner { //добавить в контракт эфир
      Storage += msg.value;
   }

   function calculateTotalSum(uint256 percent, uint256 sum, uint256 months) pure private returns(uint256){
      return (sum * ((100+percent)**months) / (100**months));
   }
}

//{value: web3.utils.toWei('2', 'ether'), from : accounts[0]}
//let bank = await Bank.deployed()
//payable ф-ции могут получать эфир
//storage переменные хранятся в блокчейне
//memory переменные = локальные, живут только в области видимости
//calldata - при взаимодействии двух контрактов для доступа к полям другого контракта
//view - можем только читать storage переменные
//pure - нет доступа к storage переменным
//<payable address ADDRESS>.transfer(uint SUM) - передача SUM эфира со счета контракта на адрес ADDRESS