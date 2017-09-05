pragma solidity 0.4.15;

contract Raffle {

    address admin;
    uint fee;
    uint end;
    uint redemption;
    uint constant betAmount = 100;
    uint totalPot;
    uint whiteballs;
    string public debugInfo;

    struct Bet {
        uint amount;
        uint whiteballs;
    }

    // mapping of ticket number to player.
    mapping(address => Bet[]) lotto;
    // list of winners.
    address[] winners;

    modifier AdminOnly() {
        if (msg.sender == admin) {
            debugInfo = concat("AdminOnly TRUE, ", toString(msg.sender));
            _;   // continue
        }
    }

    modifier InPlay() {
        if(msg.sender != admin && block.timestamp < end) {
            debugInfo = concat("InPlay TRUE, ", toString(msg.sender));
            _;   // continue
        }
    }
    
    modifier EndPlay() {
        if(msg.sender != admin && 
            block.timestamp >= end &&
            block.timestamp < redemption) {
            debugInfo = concat("EndPlay TRUE, ", toString(msg.sender));
            _;   // continue
        }
    }
    
    // constructor
    function Raffle(uint feePercent, uint unixEndTime, uint daysToRedeem) {
        require(admin == address(0));
        
        fee = feePercent;
        end = unixEndTime;
        redemption = daysToRedeem * 86400; // unix seconds in a day.
        totalPot = 0;
        admin = msg.sender;
    }
    
    function DrawWinning(uint _whiteballs) AdminOnly EndPlay {
        // prevent administrator from calling this function more than once.
        if(whiteballs != 0)
        {
            debugInfo = concat("This function has already called. It can only be called once.", toString(msg.sender));
            return;
        }

        // pay administrative fee.
        uint _tax = totalPot * fee;

        require(admin.send(_tax));

        // reduce pot size by administrative fee.
        totalPot -= _tax;

        whiteballs = _whiteballs;
    }

    function DisburseEarnings() AdminOnly EndPlay {
        // split pot amongst winners. 
        uint _earnings = totalPot / winners.length;
        
        // disburse winnings.
        for(uint i = 0; i < winners.length; i++) 
        {
            require(winners[i].send(_earnings));
        }

        // pay admin administrative fee and terminate lottery contract [reference: #2 reported by zbobbert]
        selfdestruct(admin);
    }    

    // allow the player to collect their winnings [reference: #1 reported by zbobbert]
    function CollectEarning() EndPlay {
        // calculate winner's earnings.
        uint _earnings = totalPot / winners.length;
        
        // disburse winnings.
        for(uint i = 0; i < winners.length; i++) {
            if(winners[i] == msg.sender) {
                require(winners[i].send(_earnings));
                // remove player from winners list since they have been paid.
                delete winners[i];
                // reduce the size of the pot correspondingly.
                totalPot -= _earnings;
                break;
            }
        }
    }
    
    function Play(uint _whiteballs) payable InPlay {
        // check betting amount is correct.
        if(msg.value != betAmount) {
            debugInfo = concat("bet amount is incorrect. ", toString(msg.sender));
            return;
        }

        // check if user hasn't already played the same number. 
        Bet[] storage _playerbets = lotto[msg.sender];
        // prevent players from playing the same number multiple times.
        for(uint i = 0; i < _playerbets.length; i++) {
            if(_playerbets[i].whiteballs == _whiteballs) {
                debugInfo = concat("betting on the same number not permitted. ", toString(msg.sender));
                return;
            }
        }

        // add bet to pot.
        totalPot += msg.value;
        
        // track player's bet.
        lotto[msg.sender].push(Bet({
            amount: msg.value,
            whiteballs: _whiteballs
            }));
    }
    
    function Check() EndPlay {
        if(whiteballs == 0) {
            debugInfo = concat("please check again. Winning balls have not been drawn yet. ", toString(msg.sender));
            return;
        }
        
        var _bets = lotto[msg.sender];
        
        for(uint i = 0; i < _bets.length; i++) {
            if( _bets[i].whiteballs == whiteballs ) {
                debugInfo = concat("You're a winner! ", toString(msg.sender));
                // track winners.
                winners.push(msg.sender);
            }
        }
    }

    function GetTotalPot() returns (uint) {
        return totalPot;
    }

    function debug() returns (string) {
        return debugInfo;
    }

    // Borrar cuando subamos a prod.
    function toString(address x) returns (string) {
        bytes memory b = new bytes(20);
        for (uint i = 0; i < 20; i++)
            b[i] = byte(uint8(uint(x) / (2**(8*(19 - i)))));
        return string(b);
    } 

    // Borrar cuando subamos a prod.
    function concat(string str1, string str2) returns (string) {

        bytes memory bs1 = bytes(str1);
        bytes memory bs2 = bytes(str2);

        uint len1 = bs1.length;
        uint len2 = bs2.length;

        string memory temp = new string(len1 + len2);
        bytes memory result = bytes(temp);

        uint index = 0;
        for (uint i = 0; i < len1; i++) {
            result[index++] = bs1[i];

        }
        for (i = 0; i < len2; i++) {
            result[index++] = bs2[i];

        }
        return string(result);
    }  

}