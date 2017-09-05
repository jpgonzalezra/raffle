//import "../stylesheets/app.css";

import { default as Web3} from 'web3';
import { default as contract } from 'truffle-contract'

import raffle_artifacts from '../../build/contracts/Raffle.json'

var Raffle = contract(raffle_artifacts);
var accounts;
var account;

window.App = {
  start: function() {

    var self = this;
    Raffle.setProvider(web3.currentProvider);

    web3.eth.getAccounts(function(err, accs) {
      if (err != null) {
        alert("There was an error fetching your accounts.");
        return;
      }

      if (accs.length == 0) {
        alert("Couldn't get any accounts! Make sure your Ethereum client is configured correctly.");
        return;
      }

      accounts = accs;
      account = accounts[0];

      self.listen();
    });

  },

  listen: function() {

    // Parece que en la testrpc no funciona el listening de los eventos
    Raffle.deployed().then(function(instance) {
      var events = instance.allEvents({fromBlock: 0, toBlock: 'latest'});

      events.watch(function(e, result){
        debugger
      });

      instance.allEvents({ fromBlock: 0 }, (error, result) => {
        debugger
      });
    });

  },

  Play: function() {

    let price = 0.0000000000000001; //ethers
    Raffle.deployed().then(function(instance) {
      instance.Play(13, {value: web3.toWei(price, 'ether'), from: web3.eth.accounts[0]}).then(function(result) {
        console.log(result);
      }).catch(function(e) {
        console.log(e)
      });
    });
  },

  Check: function() {

    Raffle.deployed().then(function(instance) {
      var raffle = instance;
      return raffle.Check.call({from: account});
    }).then(function(response) {
      console.log(response)
    }).catch(function(e) {
      console.log(false)
    });
  },

  GetTotalPot: function() {

    Raffle.deployed().then(function(instance) {
      var raffle = instance;
      return raffle.GetTotalPot.call({from: account});
    }).then(function(response) {
      console.log(response.toString())
    }).catch(function(e) {
      console.log(false)
    });
  },

  debug: function() {

    Raffle.deployed().then(function(instance) {
      var raffle = instance;
      return raffle.debug.call();
    }).then(function(response) {
      console.log(response.toString())
    }).catch(function(e) {
      console.log(false)
    });
  },

};

window.addEventListener('load', function() {
  if (typeof web3 !== 'undefined') {
    window.web3 = new Web3(web3.currentProvider);
  } else {
    window.web3 = new Web3(new Web3.providers.HttpProvider("http://localhost:8545"));
  }

  App.start();
});
