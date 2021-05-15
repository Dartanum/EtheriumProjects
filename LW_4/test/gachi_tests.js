const Gachi = artifacts.require("Gachi");

var BN = web3.utils.BN;
var Hex = web3.utils.toHex;
var Decimal = web3.utils.toDecimal;

contract("Gachi test", async accounts => {

    // Тест Gachi::totalSuply при деплое
    const initial_supply = 200;                                                 // начальное значение totalSupply
    it(`totalSupply должен быть равен ${initial_supply} при деплое`, async () => {
        const gachi = await Gachi.deployed();
        let supply = await gachi.totalSupply();
        assert.equal(supply, Decimal(initial_supply),                           // totalSupply изначально 200, потому что при деплое банк получает столько (см. 8 строку 3_bank_migration.js)
        `Начальное количество валюты не было равно ${initial_supply}`);      
    });

    // Тест Gachi::mint
    const payment_amount = 50;                                                  // сумма зачисления на какой-то счет
    it(`На accounts[1] должно перевестись ${payment_amount} Gachi (totalSupply также должен увеличиться на это количество)`, async () => {
        const gachi = await Gachi.deployed();
        let supply = await gachi.totalSupply();
        await gachi.mint(accounts[1], payment_amount);
        let new_supply = await gachi.totalSupply();
        let balance = await gachi.balanceOf(accounts[1]);
        assert.equal(balance, Decimal(payment_amount));                         // проверка, что баланс на accounts[1] стал равен payment_amount
        assert.equal(new_supply, Decimal(supply) + payment_amount);             // проверка, что totalSupply увеличился на payment_amount
    });

    // Тест Gachi::transfer
    it(`На accounts[2] с accounts[1] должно перевестись ${payment_amount} Gachi`, async () => {
        const gachi = await Gachi.deployed();
        let balance_1_before_transfer = await gachi.balanceOf(accounts[1]);     // баланс account[1] до трансфера и до выдачи денег
        await gachi.mint(accounts[1], payment_amount);                          // выдаем деньги первому аккаунту
        let balance_2_before_transfer = await gachi.balanceOf(accounts[2]);     // баланс account[2] до трансфера
        await gachi.transfer(accounts[2], payment_amount, {from: accounts[1]}); 
        let balance_1_after_transfer = await gachi.balanceOf(accounts[1]);      // баланс account[1] после трансфера
        let balance_2_after_transfer = await gachi.balanceOf(accounts[2]);      // баланс account[2] после трансфера
        assert.equal(balance_1_before_transfer, Decimal(balance_1_after_transfer));
        assert.equal(balance_2_before_transfer, Decimal(balance_2_after_transfer) - payment_amount);
    });
})