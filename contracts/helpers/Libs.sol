// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

contract Libs {
    uint256[] public sortedArray;

    function calculateExpertAmount(uint256 players)
        public
        pure
        returns (uint256)
    {
        // TODO rewrite to formula
        if (players <= 2) {
            return 1;
        } else if (players >= 3 && players <= 11) {
            return 3;
        } else if (players >= 12 && players <= 30) {
            return 5;
        } else if (players >= 31 && players <= 56) {
            return 7;
        } else if (players >= 57 && players <= 91) {
            return 9;
        } else if (players >= 92 && players <= 133) {
            return 11;
        } else if (players >= 134 && players <= 300) {
            return 15;
        } else if (players >= 301 && players <= 500) {
            return 23;
        } else if (players >= 501 && players <= 1000) {
            return 33;
        } else if (players >= 1001 && players <= 5000) {
            return 70;
        } else {
            return 100;
        }
    }

    function getPersent(uint256 _percent, uint256 _from)
        public
        pure
        returns (uint256)
    {
        return (_from * _percent) / 100;
    }

    function setSort(uint256[] memory _data) public {
        sortedArray = _data;
    }

    function sort() public {
        if (sortedArray.length == 0) return;
        quickSort(sortedArray, 0, sortedArray.length - 1);
    }

    function quickSort(
        uint256[] storage arr,
        uint256 left,
        uint256 right
    ) internal {
        uint256 i = left;
        uint256 j = right;
        uint256 pivot = arr[left + (right - left) / 2];
        while (i <= j) {
            while (arr[i] < pivot) i++;
            while (pivot < arr[j]) j--;
            if (i <= j) {
                (arr[i], arr[j]) = (arr[j], arr[i]);
                i++;
                j--;
            }
        }
        if (left < j) quickSort(arr, left, j);

        if (i < right) quickSort(arr, i, right);
    }
}
