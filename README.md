# Raffle

Si es la primera vez que te bajas el proyecto

```
npm install
```

## TESTRPC

### RUN RPC NODE

```
node_modules/.bin/testrpc
```

### CREAR CUENTA

```
truffle(default)> web3.personal.newAccount('verystrongpassword')
'0x95a94979d86d9c32d1d2ab5ace2dcc8d1b446fa1'
truffle(default)> web3.eth.getBalance('0x95a94979d86d9c32d1d2ab5ace2dcc8d1b446fa1')
{ [String: '0'] s: 1, e: 0, c: [ 0 ] }
truffle(default)> web3.personal.unlockAccount('0x95a94979d86d9c32d1d2ab5ace2dcc8d1b446fa1', 'verystrongpassword', 15000)
```

y darle ethers desde METAMASK

### COMPILAR, DEPLOYAR Y PROBAR

```
truffle(default)> compile
truffle(default)> migrate --reset
truffle(default)> Raffle.deployed().then(function(contractInstance) {contractInstance.GetTotalPot.call().then(function(v) {console.log(v)})})
```

### ACCEDER A PROPIEDADES DEL CONTRATO

```
truffle(default)> Raffle.deployed().then(function(contractInstance) {console.log(contractInstance.address)})
```

## SITES IMPORTANTES

UNIX TIME https://www.unixtimestamp.com/index.php
WEI CONVERTER https://etherconverter.online/
BLOCKCHAIN EXPLORER https://ropsten.etherscan.io/address/0x6823e2d47577eb87d97a75b7667488f50421ff7b#code