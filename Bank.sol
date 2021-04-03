pragma solidity >=0.4.22 <0.7.0;

contract Bank {

   struct Credit {
      uint percentageRate; //процентная ставка
      uint currentSum; //сумма кредита
      uint months; //срок в месяцах
   }
   struct Client {
      address payable id; //адрес клиента
      string login;
      string password;
      uint balance;
      Credit credit;
   }
   uint private Storage; //количество эфира в контракте
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

   event RegisterError(address id, string message); //события (аналоги логов), вызываются в функциях с введенными параметрами

   event RegisterSuccess(address id, string message);

   event TakeCredit(address id, uint percent, uint sum, uint number_month);

   function register(string memory login, string memory password) public payable { //регистрация нового клиента
      bool isExist = false;
      Client memory newClient = Client(msg.sender, login, password, msg.value, Credit(0, 0, 0));
      for(uint i = 0; i < numberClient; i++) { //в цикле поиск по зарегистрированным клиентам и проверка есть ли такой пользователь, который сейчас регистрируется
         require(clients[i].id != msg.sender);
         if(keccak256(bytes(clients[i].login)) == keccak256(bytes(newClient.login))) { //сравнение логинов
            emit RegisterError(msg.sender, "This login already exist");
            isExist = true;
            break;
         }
      }
      if(!isExist) { //если такой пользователь не зарегистрирован
         emit RegisterSuccess(msg.sender, "Success register");
         clients.push(newClient); //добавление нового клиента в массив клиентов
         numberClient++;
      }
   }

   function checkClient(Client memory current, string memory login, string memory password) private pure returns(bool) { //pure ф-ция не использует storage переменные
      return (keccak256(bytes(current.login)) == keccak256(bytes(login))) && (keccak256(bytes(current.password)) == keccak256(bytes(password))); //сравнение логинов и паролей
   }
   //ф-ция взятия кредита
   function takeCredit(string memory login, string memory password, uint percent, uint num, uint month) public { //percent - процентная ставка, num - сколько взял, month - на сколько
      for(uint i = 0; i < numberClient; i++) {
         if(checkClient(clients[i], login, password)) { //поиск пользователя, на которого взять кредит
            clients[i].balance += num; //добавляем сумму кредита клиенту
            clients[i].credit = Credit(percent, num, month); //создаем кредит
            clients[i].id.transfer(num); //отправляем эфир из контракта пользователю
            Storage -= num; //уменьшаем кол-во эфира в контракте
            emit TakeCredit(msg.sender, percent, clients[i].id.balance, month);
            break;
         }
      }
   }

   function getStorage() public view checkOwner returns(uint) { //узнать сколько эфир в хранилище
      return Storage;
   }

   function addToStorage() public payable checkOwner { //добавить в контракт эфир
      Storage += msg.value;
   }
}

//{value: web3.utils.toWei('2', 'ether'), from : accounts[0]}
//payable ф-ции могут получать эфир
//storage переменные хранятся в блокчейне
//memory переменные = локальные, живут только в области видимости
//calldata - при взаимодействии двух контрактов для доступа к полям другого контракта
//view - можем только читать storage переменные
//pure - нет доступа к storage переменным
//<payable address ADDRESS>.transfer(uint SUM) - передача SUM эфира со счета контракта на адрес ADDRESS