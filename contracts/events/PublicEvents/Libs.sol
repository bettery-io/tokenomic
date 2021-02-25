// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

contract Libs {
    uint256[] public sortedArray;

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
