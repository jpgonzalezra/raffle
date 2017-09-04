import "../stylesheets/app.css";

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
    
    /*Raffle.deployed().then(function(instance) {
      instance.Logging(
        {},
        {fromBlock: 0, toBlock: 'latest'},
        function(error, event){
          console.log(error, event);
        }
      )
    });*/

    /*Raffle.deployed().then(function(instance) {
      var allEvents = instance.allEvents({fromBlock: 0, toBlock: 'latest'}, (err, event) => {
        console.log(err, event)
      });
      allEvents.get(function(error, events){
        console.log(error, events)
      });
    });*/

    /*Raffle.deployed().then(function(instance) {
      instance.Logging({_caller: account}, {
        fromBlock: 0,
        toBlock: 'latest'
      }, (err, event) => {
        console.log(err, event)
      }).watch(function (err, result) {
        if (err) console.log(err)
        console.log(result)
      })
    });*/

    /*
    Raffle.deployed().then(function(instance) {
      instance.allEvents({}, {
        fromBlock: 0,
        toBlock: 'latest'
      }, (err, event) => {
        console.log(err, event)
      }).watch(function (err, result) {
        if (err) console.log(err)
        console.log(result)
      })
    })*/

  },

  Log: function() {

    Raffle.deployed().then(function(instance) {
      var raffle = instance;
      return raffle.Log.call({from: account});
    }).then(function(response) {
      console.log(response)
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
