import NonFungibleToken from 0x06

pub contract CryptoPoops: NonFungibleToken {
  pub var totalSupply: UInt64

  pub event ContractInitialized()
  pub event Withdraw(id: UInt64, from: Address?)
  pub event Deposit(id: UInt64, to: Address?)

  pub resource NonFungibleToken: NonFungibleToken.INonFungibleToken {
    pub let id: UInt64

    pub let name: String
    pub let favouriteFood: String
    pub let luckyNumber: Int

    init(_name: String, _favouriteFood: String, _luckyNumber: Int) {
      self.id = self.uuid

      self.name = _name
      self.favouriteFood = _favouriteFood
      self.luckyNumber = _luckyNumber
    }
  }
  
  pub resource interface CollectionPublic {
    pub fun borrowAuthNonFungibleToken(id: UInt64): &NonFungibleToken 
}

pub resource Collection: CollectionPublic, NonFungibleToken.Provider, NonFungibleToken.Receiver, NonFungibleToken.CollectionPublic {
    pub var ownedNonFungibleTokens: @{UInt64: NonFungibleToken.NonFungibleToken}

    pub fun withdraw(withdrawID: UInt64): @NonFungibleToken.NonFungibleToken {
      let NonFungibleToken <- self.ownedNonFungibleTokens.remove(key: withdrawID) 
            ?? panic("This NonFungibleToken does not exist in this Collection.")
      emit Withdraw(id: NonFungibleToken.id, from: self.owner?.address)
      return <- NonFungibleToken
    }

    pub fun deposit(token: @NonFungibleToken.NonFungibleToken) {
      let NonFungibleToken <- token as! @NonFungibleToken
      emit Deposit(id: NonFungibleToken.id, to: self.owner?.address)
      self.ownedNonFungibleTokens[NonFungibleToken.id] <-! NonFungibleToken
    }

    pub fun getIDs(): [UInt64] {
      return self.ownedNonFungibleTokens.keys
    }

    pub fun borrowNonFungibleToken(id: UInt64): &NonFungibleToken.NonFungibleToken {
      return (&self.ownedNonFungibleTokens[id] as &NonFungibleToken.NonFungibleToken?)!
    }

    pub fun borrowAuthNonFungibleToken(id: UInt64): &NonFungibleToken {
        let ref = (&self.ownedNonFungibleTokens[id] as auth &NonFungibleToken.NonFungibleToken?)!
        return ref as! &NonFungibleToken
    }

    init() {
      self.ownedNonFungibleTokens <- {}
    }

    destroy() {
      destroy self.ownedNonFungibleTokens
    }
  }

  pub fun createEmptyCollection(): @NonFungibleToken.Collection {
    return <- create Collection()
  }

  pub resource Minter {

    pub fun createNonFungibleToken(name: String, favouriteFood: String, luckyNumber: Int): @NonFungibleToken {
      return <- create NonFungibleToken(_name: name, _favouriteFood: favouriteFood, _luckyNumber: luckyNumber)
    }

    pub fun createMinter(): @Minter {
      return <- create Minter()
    }

  }

  init() {
    self.totalSupply = 0
    emit ContractInitialized()
    self.account.save(<- create Minter(), to: /storage/Minter)
  }
}
