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

import {VRFConsumerBaseV2Plus} from "@chainlink/contracts/src/v0.8/vrf/dev/VRFConsumerBaseV2Plus.sol";
import {VRFV2PlusClient} from "@chainlink/contracts/src/v0.8/vrf/dev/libraries/VRFV2PlusClient.sol";
import {IVRFCoordinatorV2Plus} from "@chainlink/contracts/src/v0.8/vrf/dev/interfaces/IVRFCoordinatorV2Plus.sol";

contract Raffle is VRFConsumerBaseV2Plus {
    /*Errors*/
    error Raffle__SendMoreToEnterRaffle();
    error Raffle__TransferFailed();
    error Raffle__RaffleNotOpen();
    error Raffle__UpkeepNotNeeded(uint256 balance, uint256 playersLength, uint256 raffleState);

    /*Type Declarations*/
    enum RaffleState {
        OPEN,
        CALCULATING
    }

    /*State Variables*/
    uint16 private constant REQUEST_CONFIRMATIONS = 3;
    uint32 private constant NUM_WORDS = 1;
    // Entrance fee for the raffle (set at contract deployment)
    uint256 private immutable i_entranceFee;

    // @dev the duration of an interval in seconds
    uint256 private immutable i_interval;
    bytes32 private immutable i_keyHash;
    uint256 private immutable i_subscriptionId;
    uint32 private immutable i_callbackGasLimit;
    // List of players who have entered the raffle
    address payable[] private s_players;
    uint256 private s_lastTimeStamp;
    address private s_recentWinner;
    RaffleState private s_raffleState;

    /*Events*/
    // Event emitted when a player enters the raffle
    event RaffleEntered(address indexed player);
    event WinnerPicked(address indexed winner);

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
        i_keyHash = gasLane;
        i_subscriptionId = subscriptionId;
        i_callbackGasLimit = callbackGasLimit;

        s_lastTimeStamp = block.timestamp;
        s_raffleState = RaffleState.OPEN;
    }

    // Function to enter the raffle. Requires sending enough ETH.
    function enterRaffle() public payable {
        if (msg.value < i_entranceFee) {
            revert Raffle__SendMoreToEnterRaffle();
        }
        if (s_raffleState != RaffleState.OPEN) {
            revert Raffle__RaffleNotOpen();
        }

        s_players.push(payable(msg.sender));
        emit RaffleEntered(msg.sender);
    }

    /**
     * @dev this is the function that the chainlink nodes will call to see
     * if the lottery is ready to hace a winner picked
     * The followwing shoukd be true in order for upkeepNeeded to be true:
     *     1. tht time interval has passed between the last time a winner was picked
     *     2. The lottery is in an open state
     *     3. The contract has ETH
     *     4. Implicitly your subscription is funded with LINK
     *     @param - Ignored
     *     @return upkeepNeeded - true if its time to restart the lottery
     *     @return - Ignored
     */
    function checkUpkeep(bytes memory /*checkData*/ )
        public
        view
        returns (
            bool upkeepNeeded,
            bytes memory /*performData*/ //upkeepNeeded defaults as false
        )
    {
        bool timeHasPassed = (block.timestamp - s_lastTimeStamp) >= i_interval;
        bool isOpen = (s_raffleState == RaffleState.OPEN);
        bool hasBalance = address(this).balance > 0;
        bool hasPlayers = s_players.length > 0;

        upkeepNeeded = timeHasPassed && isOpen && hasBalance && hasPlayers;
        return (upkeepNeeded, ""); // The second return value is not used in this case, so we return an empty bytes array
            // it will return true if the time has passed, the raffle is open, the contract has balance and there are players
            // It returns upkeepNeeded
    }

    // Function to pick a winner
    function performUpkeep(bytes calldata /*performData*/ ) external {
        (bool upkeepNeeded,) = checkUpkeep("");
        if (!upkeepNeeded) {
            revert Raffle__UpkeepNotNeeded(address(this).balance, s_players.length, uint256(s_raffleState));
        }

        s_raffleState = RaffleState.CALCULATING;
        VRFV2PlusClient.RandomWordsRequest memory request = VRFV2PlusClient.RandomWordsRequest({
            keyHash: i_keyHash,
            subId: i_subscriptionId,
            requestConfirmations: REQUEST_CONFIRMATIONS,
            callbackGasLimit: i_callbackGasLimit,
            numWords: NUM_WORDS,
            extraArgs: VRFV2PlusClient._argsToBytes(VRFV2PlusClient.ExtraArgsV1({nativePayment: false}))
        });
        s_vrfCoordinator.requestRandomWords(request);
    }

    function fulfillRandomWords(uint256 requestId, uint256[] calldata randomWords) internal override {
        uint256 indexOfWinner = randomWords[0] % s_players.length;
        address payable recentWinner = s_players[indexOfWinner];
        s_recentWinner = recentWinner;

        s_raffleState = RaffleState.OPEN;
        s_players = new address payable[](0); // Reset the players array
        s_lastTimeStamp = block.timestamp; //restart the timer

        (bool success,) = recentWinner.call{value: address(this).balance}("");
        if (!success) {
            revert Raffle__TransferFailed();
        }
        emit WinnerPicked(s_recentWinner);
    }

    /**
     * Getter Functions
     */
    // Returns the current entrance fee
    function getEntranceFee() external view returns (uint256) {
        return i_entranceFee;
    }

    function getRaffleState() external view returns (RaffleState) {
        return s_raffleState;
    }

    function getPlayer(uint256 index) external view returns (address) {
        return s_players[index];
    }
}
