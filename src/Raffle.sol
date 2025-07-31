// Layout of Contract:
//1. version                   --> Ej: pragma solidity ^0.8.19;
//2. imports                   --> Importaciones de librerías, interfaces, etc.
//3. errors                    --> Definiciones de errores personalizados.
//4. interfaces, libraries... --> Si definís librerías o interfaces internas.
//5. Type declarations         --> Structs, enums, etc.
//6. State variables           --> Variables como i_entranceFee
//7. Events                    --> Eventos como WinnerPicked
//8. Modifiers                 --> Reglas para funciones, como onlyOwner
//9. Functions                 --> Todas las funciones

// Layout of Functions:
//1. constructor
//2. receive()                --> Recibe ether sin datos
//3. fallback()              --> Llamado cuando no existe la función
//4. external                --> Funciones públicas llamadas desde afuera
//5. public
//6. internal
//7. private
//8. view / pure             --> Funciones de solo lectura o cálculo


// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {VRFConsumerBaseV2Plus} from "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";
import {VRFV2PlusClient} from "@chainlink/contracts/src/v0.8/VRFV2PlusClient.sol";

contract Raffle is VRFConsumerBaseV2Plus {

    // Custom error to indicate insufficient ETH sent to enter the raffle
    error Raffle__SendMoreToEnterRaffle();

    uint16 private constant REQUEST_CONFIRMATIONS = 3;
    uint32 private constant NUM_WORDS = 1;
    // Entrance fee for the raffle (set at contract deployment)
    uint256 private immutable i_entranceFee;

    // @dev the duration of an interval in seconds
    uint256 private immutable i_interval;
    uint256 private immutable i_subscriptionId;
    uint32 private immutable i_callbackGasLimit;
    // List of players who have entered the raffle
    address payable[] private s_players;
    uint256 private s_lastTimeStamp;
    bytes32 private immutable i_keyHash;

    /*Events*/
    // Event emitted when a player enters the raffle
    event RaffleEntered(address indexed player);

    // Constructor: initializes the entrance fee
    constructor(
        uint256 entranceFee,
        uint256 interval,
        address vrfCoordinator,
        bytes32 gasLane,
        uint256 subscriptionId,
        uint32 callbackGasLimit
    ) VRFConsumerBaseV2Plus(vrfCoordinator) {
        i_entranceFee = entranceFee;
        i_interval = interval;
        i_subscriptionId = subscriptionId;
        i_callbackGasLimit = callbackGasLimit;
        s_lastTimeStamp = block.timestamp;
        i_keyHash = gasLane;
    }

    // Function to enter the raffle. Requires sending enough ETH.
    function enterRaffle() public payable{
       if (msg.value < i_entranceFee) {
           revert Raffle__SendMoreToEnterRaffle();
       }
       s_players.push(payable(msg.sender));
       emit RaffleEntered(msg.sender);
    }   

    // Function to pick a winner 
    function pickWinner() external {
        if(block.timestamp - s_lastTimeStamp > i_interval) {
            revert();
        }
        VRFV2PlusClient.RandomWordsRequest memory request = VRFV2PlusClient.RandomWordsRequest({
            keyHash: i_keyHash,
            subId: i_subscriptionId,
            requestConfirmations: REQUEST_CONFIRMATIONS,
            callbackGasLimit: i_callbackGasLimit,
            numWords: NUM_WORDS,
            extraArgs: VRFV2PlusClient._argsToBytes(
                VRFV2PlusClient.extraArgsV1({nativePayment: false})
            )
        });
        uint256 requestId = s_vrfCoordinator.requestRandomWords(request);
    }

    function fulfillRandomWords(uint256 requestId, uint256[] calldata randomWords) internal override {
        // Logic to handle the random words and pick a winner
        // This function will be called by the VRF Coordinator with the random words
        // You can implement your winner selection logic here
    }

    /** Getter Functions*/
    // Returns the current entrance fee
    function getEntranceFee() external view returns (uint256) {
        return i_entranceFee;
    }
}
