pragma solidity 0.4.15;

contract Raffle 
{
    address admin;
    uint fee;
    uint end;
    uint redemption;
    uint constant betAmount = 100;
    uint totalPot;
    uint whiteballs;

    struct Bet 
    {
        uint amount;
        uint whiteballs;
    }

    // mapping of ticket number to player.
    mapping(address => Bet[]) lotto;
    // list of winners.
    address[] winners;

    modifier AdminOnly() 
    {
        if (msg.sender == admin) 
        {
            SimpleLogging("AdminOnly TRUE");
            _;   // continue
        }
    }

    modifier InPlay() 
    {
        if(msg.sender != admin && block.timestamp < end) 
        {
            SimpleLogging("InPlay TRUE");
            _;   // continue
        }
    }
    
    modifier EndPlay() 
    {
        if(msg.sender != admin && 
            block.timestamp >= end &&
            block.timestamp < redemption) 
        {
            SimpleLogging("EndPlay TRUE");
            _;   // continue
        }
    }

    event Logging(string output, address caller);
    event SimpleLogging(string output);
    
    // constructor
    function Raffle(uint feePercent, uint unixEndTime, uint daysToRedeem) 
    {
        require(admin == address(0));
        
        fee = feePercent;
        end = unixEndTime;
        redemption = daysToRedeem * 86400; // unix seconds in a day.
        totalPot = 0;
        admin = msg.sender;
    }
    
    function DrawWinning(uint _whiteballs) AdminOnly EndPlay 
    {
        // prevent administrator from calling this function more than once.
        if(whiteballs != 0)
        {
            Logging("This function has already called. It can only be called once.", msg.sender);
            return;
        }

        // pay administrative fee.
        uint _tax = totalPot * fee;

        require(admin.send(_tax));

        // reduce pot size by administrative fee.
        totalPot -= _tax;

        whiteballs = _whiteballs;
    }

    function DisburseEarnings() AdminOnly EndPlay 
    {
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
    function CollectEarning() EndPlay
    {
        // calculate winner's earnings.
        uint _earnings = totalPot / winners.length;
        
        // disburse winnings.
        for(uint i = 0; i < winners.length; i++) 
        {
            if(winners[i] == msg.sender)
            {
                require(winners[i].send(_earnings));
                // remove player from winners list since they have been paid.
                delete winners[i];
                // reduce the size of the pot correspondingly.
                totalPot -= _earnings;
                break;
            }
        }
    }
    
    function Play(uint _whiteballs) payable InPlay 
    {
        // check betting amount is correct.
        if(msg.value != betAmount) 
        {
            Logging("bet amount is incorrect", msg.sender);
            return;
        }

        // check if user hasn't already played the same number. 
        Bet[] storage _playerbets = lotto[msg.sender];
        // prevent players from playing the same number multiple times.
        for(uint i = 0; i < _playerbets.length; i++) 
        {
            if(_playerbets[i].whiteballs == _whiteballs) 
            {
                Logging("betting on the same number not permitted", msg.sender);
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
    
    function Check() EndPlay 
    {
        if(whiteballs == 0) 
        {
            Logging("please check again. Winning balls have not been drawn yet.", msg.sender);
            return;
        }
        
        var _bets = lotto[msg.sender];
        
        for(uint i = 0; i < _bets.length; i++) 
        {
            if( _bets[i].whiteballs == whiteballs ) 
            {
                Logging("You're a winner!", msg.sender);
                // track winners.
                winners.push(msg.sender);
            }
        }
    }

    function GetTotalPot() returns (uint)
    {
        return totalPot;
    }

}