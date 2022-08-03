![](cover.png)

**A set of challenges to learn offensive security of smart contracts in Ethereum.**

Featuring flash loans, price oracles, governance, NFTs, lending pools, smart contract wallets, timelocks, and more!

## Play

Visit [damnvulnerabledefi.xyz](https://damnvulnerabledefi.xyz)

## Disclaimer

All Solidity code, practices and patterns in this repository are DAMN VULNERABLE and for educational purposes only.

DO NOT USE IN PRODUCTION.

# Challenge #1 - Unstoppable

In this first challenge, we are asked to stop a lending pool from offeing flash loans. The pool has 10M DVT tokens and we have 100 DVT of them.

### Solution:

We can navigate through the smart contracts and seek for anything wrong, but where? Well, if we check the JS challenge file that we will use `unstoppable.challenge.js` we can already see that we are looking for a revert of the `executeFlashLoan()` method:

```
await expect(this.receiverContract.executeFlashLoan(10)).to.be.reverted;
```

If we go into that function, we see several conditions that must be fulfilled. Thus, we should break one of them in order to complete our challenge:

```
require(borrowAmount > 0, "Must borrow at least one token");
require(balanceBefore >= borrowAmount, "Not enough tokens in pool");
assert(poolBalance == balanceBefore);
require(balanceAfter >= balanceBefore, "Flash loan hasn't been paid back");
```

There are several variables that intervene in those conditions. Both `balanceBefore` and `balanceAfter` are obtained from the well-known `ERC20.balanceOf()` method, assuming there should not be any issue here.

Then there is `borrowAmount`, which is set by the borrower. This variable has to be above `0` and also smaller than the balance of the pool; otherwise the transaction will revert. But only the transaction would be reverted if the conditions around `borrowAmount`: we are looking to break the whole contract so that nobody can use it anymore.

The last option we have is to inspect `poolBalance`. There is an extra note in the contracts regarding this variable, saying it is:

```
// Ensured by the protocol via the `depositTokens` function
```

So and what is the relationship it has with `poolBalance`? When using that function to deposit DVT tokens, the poolBalance will be updated:

```
poolBalance = poolBalance + amount;
```

Therefore, when this function is used to send tokens to the pool, `poolBalance` will be updated with such amount, and when comparing it with `ERC20.balanceOf()` we will fulfill the assert condition.

So all good, right? Right..? Well, not really... The `depositTokens` function is not the only way to send tokens to the contract. We can just send them directly as in any other wallet! And, by doing that, `poolBalance` would not update, while `ERC20.balanceOf()` would show the updated amount. As a result, the assert would be false, reverting any transaction trying to use the flash loan!
