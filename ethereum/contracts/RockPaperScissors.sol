// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import "./RPSToken.sol";

contract RockPaperScissors {
    RPSToken token;
    address public owner;
    uint256 public prize;
    uint256 public minBalance;
    uint256 public minRoundsPerGame;

    mapping(address => uint256) public playersBalances;

    uint256 public gamesCount;
    mapping(address => uint256) public gamesCountPerAddress;
    mapping(address => mapping(uint256 => Game)) public gameStructs;
    mapping(address => mapping(uint256 => Round[])) public roundsPerGame;

    enum Choice {
        ROCK,
        PAPER,
        SCISSORS,
        NONE
    }

    enum Status {
        STARTED,
        ENDED
    }

    enum Winner {
        PLAYER,
        CONTRACT,
        DRAW
    }

    struct Round {
        uint256 number;
        Choice pChoice;
        Choice cChoice;
        Winner winner;
    }

    struct Game {
        Status status;
        Winner winner;
        Round[] rounds;
    }

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    constructor(
        address _token,
        uint256 _prize,
        uint256 _minBalance,
        uint256 _roundsPerGame
    ) {
        owner = msg.sender;
        token = RPSToken(_token);
        prize = prize;
        minBalance = _minBalance;
        minRoundsPerGame = _roundsPerGame;
    }

    function deposit(uint256 amount) public onlyOwner {
        token.transferFrom(owner, address(this), amount);
    }

    function withdraw(uint256 amount) public onlyOwner {
        token.transferFrom(address(this), owner, amount);
    }

    function playerDeposit(uint256 amount) public {
        address player = msg.sender;
        playersBalances[player] += amount;
        token.transferFrom(player, address(this), amount);
    }

    function playerWithdraw(uint256 amount) public {
        address player = msg.sender;
        require(amount <= playersBalances[player]);
        playersBalances[player] -= amount;
        token.transferFrom(address(this), player, amount);
    }

    function startGame() public {
        address player = msg.sender;
        uint256 balance = playersBalances[player];
        require(balance >= minBalance);

        gamesCount++;
        gamesCountPerAddress[player] = gamesCount;
        uint256 gameID = gamesCountPerAddress[player];

        Game memory game = gameStructs[player][gameID];
        game.status = Status.STARTED;
    }

    function endGame() public view {
        address player = msg.sender;
        uint256 gameID = gamesCountPerAddress[player];
        Game memory game = gameStructs[player][gameID];
        game.status = Status.ENDED;
        game.winner = Winner.CONTRACT;
    }

    function submitChoice(Choice pChoice) public {
        address player = msg.sender;
        uint256 gameID = gamesCountPerAddress[player];
        Game memory game = gameStructs[player][gameID];
        require(game.status == Status.STARTED);

        uint256 roundCount = roundsPerGame[player][gameID].length;

        if (roundCount < minRoundsPerGame) {
            Choice cChoice = getContractChoice();
            Round memory round = Round({
                number: roundCount,
                pChoice: pChoice,
                cChoice: cChoice,
                winner: determineRoundWinner(pChoice, cChoice)
            });
            roundsPerGame[player][gameID].push(round);
        } else {
            Winner winner = determineGameWinner(roundsPerGame[player][gameID]);
            game.winner = winner;
            game.status = Status.ENDED;

            if (winner == Winner.PLAYER) {
                playersBalances[player] += prize;
            } else {
                playersBalances[player] -= minBalance;
            }
        }
    }

    function determineRoundWinner(Choice _pChoice, Choice _cChoice)
        private
        pure
        returns (Winner)
    {
        if (_pChoice == _cChoice) {
            return Winner.DRAW;
        } else if (
            (_pChoice == Choice.ROCK && _cChoice == Choice.SCISSORS) ||
            (_pChoice == Choice.PAPER && _cChoice == Choice.ROCK) ||
            (_pChoice == Choice.SCISSORS && _cChoice == Choice.PAPER)
        ) {
            return Winner.PLAYER;
        } else {
            return Winner.CONTRACT;
        }
    }

    function determineGameWinner(Round[] memory rounds)
        private
        pure
        returns (Winner)
    {
        uint256 pWinsCount;
        uint256 cWinsCount;

        for (uint256 index = 0; index < rounds.length; index++) {
            if (rounds[index].winner == Winner.PLAYER) {
                pWinsCount++;
            } else {
                cWinsCount;
            }
        }

        if (pWinsCount > cWinsCount) {
            return Winner.PLAYER;
        } else if (pWinsCount < cWinsCount) {
            return Winner.CONTRACT;
        } else {
            return Winner.DRAW;
        }
    }

    function getRandomInteger() private view returns (uint256) {
        return
            uint256(
                keccak256(
                    abi.encodePacked(
                        block.timestamp,
                        block.difficulty,
                        msg.sender
                    )
                )
            ) % 3;
    }

    function getContractChoice() private view returns (Choice) {
        uint256 rnd = getRandomInteger();
        if (rnd == 1) {
            return Choice.ROCK;
        } else if (rnd == 2) {
            return Choice.PAPER;
        } else if (rnd == 3) {
            return Choice.SCISSORS;
        } else {
            return Choice.NONE;
        }
    }
}
