import './App.css';
import { useState, useEffect } from 'react';

const App = () => {
    const [ethBalance, setEthBalance] = useState();
    const [tokenBalance, setTokenBalance] = useState();
    const [roundsCount, setRoundsCount] = useState(10);
    const [currentRound, setCurrentRound] = useState(0);
    const [playerChoice, setPlayerChoice] = useState();
    const [computerChoice, setComputerChoice] = useState();
    const [winner, setWinner] = useState();

    const renderChoices = () => {
        while (currentRound < roundsCount) {
            return (
                <div>
                    <span className='choice' role='img' aria-label='rock'>
                        &#9994;
                    </span>
                    <span className='choice' role='img' aria-label='paper'>
                        &#9995;
                    </span>
                    <span className='choice' role='img' aria-label='scissors'>
                        &#9996;
                    </span>
                </div>
            );
        }
    };

    return (
        <div>
            <h1>Play Rock Paper Scissors</h1>
            {renderChoices()}
        </div>
    );
};

export default App;
