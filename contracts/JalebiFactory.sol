// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import './interfaces/IJalebiFactory.sol';
import './JalebiPair.sol';

contract JalebiFactory {
    bytes32 public constant INIT_CODE_PAIR_HASH = keccak256(abi.encodePacked(type(JalebiPair).creationCode));
    
    address public feeTo;
    address public feeToSetter;

    /// @notice store address of the pair contracts
    mapping(address => mapping(address => address)) public getPair;
    /// @notice store list of all the pairs
    address[] public allPairs;

    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    constructor(address _feeToSetter) {
        feeToSetter = _feeToSetter;
    }

    /**
        @notice function to get number of pairs created
    */
    function allPairsLength() external view returns (uint) {
        return allPairs.length;
    }

    /**
        @notice function to create the pair
        @param tokenA address of the first token
        @param tokenB address of the second token
    */
    function createPair(address tokenA, address tokenB) external returns (address pair) {
        require(tokenA != tokenB, 'Jalebi: IDENTICAL_ADDRESSES');
        (address token0, address token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
        require(token0 != address(0), 'Jalebi: ZERO_ADDRESS');
        require(getPair[token0][token1] == address(0), 'Jalebi: PAIR_EXISTS'); // single check is sufficient
        bytes memory bytecode = type(JalebiPair).creationCode;
        bytes32 salt = keccak256(abi.encodePacked(token0, token1));
        assembly {
            pair := create2(0, add(bytecode, 32), mload(bytecode), salt)
        }
        IJalebiPair(pair).initialize(token0, token1);
        getPair[token0][token1] = pair;
        getPair[token1][token0] = pair; // populate mapping in the reverse direction
        allPairs.push(pair);
        emit PairCreated(token0, token1, pair, allPairs.length);
    }

    /**
        @notice function to set the fee recipient
        @param _feeTo address of the fee recipient
    */
    function setFeeTo(address _feeTo) external {
        require(msg.sender == feeToSetter, 'Jalebi: FORBIDDEN');
        feeTo = _feeTo;
    }

    /**
        @notice function to set the address of who will set the feeTo address
        @param _feeToSetter address of the setter
    */
    function setFeeToSetter(address _feeToSetter) external {
        require(msg.sender == feeToSetter, 'Jalebi: FORBIDDEN');
        feeToSetter = _feeToSetter;
    }
}
