import CryptoPoops from 0x05
import NonFungibleToken from 0x06

transaction {

prepare(signer: AuthAccount) {  
  let myResource <- CryptoPoops.createEmptyCollection()
  signer.save(<- myResource, to: /storage/MyResource) 
  signer.link<&CryptoPoops.Collection{CryptoPoops.CollectionPublic, NonFungibleToken.Provider, NonFungibleToken.Receiver, NonFungibleToken.CollectionPublic}>(/public/MyResource, target: /storage/MyResource) 
}

  execute{
  log("collection created");
  }
}
