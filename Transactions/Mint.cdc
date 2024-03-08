import CryptoPoops from 0x05
import NonFungibleToken from 0x06

transaction(recipient: Address, name: String, favouriteFood: String, luckyNumber: Int) {

prepare(signer: AuthAccount) {  
  let myResource <- CryptoPoops.createEmptyCollection()
  signer.save(<- myResource, to: /storage/MyResource) 
  signer.link<&CryptoPoops.Collection{CryptoPoops.CollectionPublic, NonFungibleToken.Provider, NonFungibleToken.Receiver, NonFungibleToken.CollectionPublic}>(/public/MyResource, target: /storage/MyResource)

  let minter = signer.borrow<&CryptoPoops.Minter>(from: /storage/Minter)
    ?? panic("This signer is not the one who deployed the contract.")

  let recipientsCollection = getAccount(recipient).getCapability(/public/MyResource)
  .borrow<&CryptoPoops.Collection{CryptoPoops.CollectionPublic, NonFungibleToken.Provider, NonFungibleToken.Receiver, NonFungibleToken.CollectionPublic}>()
  ?? panic("The recipient does not have a Collection.")

  let nft <- minter.createNFT(name: name, favouriteFood: favouriteFood, luckyNumber: luckyNumber)
  recipientsCollection.deposit(token: <- nft)
  }
}
