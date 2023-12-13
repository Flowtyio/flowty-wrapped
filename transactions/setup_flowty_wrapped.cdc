import "NonFungibleToken"
import "FlowtyWrapped"
import "MetadataViews"

transaction {

    prepare(signer: AuthAccount) {

        // Return early if the account already stores a ExampleToken Vault
        if signer.borrow<&FlowtyWrapped.Collection>(from: FlowtyWrapped.CollectionStoragePath) == nil {
            // Create a new ExampleToken Vault and put it in storage
            signer.save(
                <-FlowtyWrapped.createEmptyCollection(),
                to: FlowtyWrapped.CollectionStoragePath
            )

            // Create a public capability to the Vault that only exposes
            // the balance field through the Balance interface
            signer.link<&FlowtyWrapped.Collection{NonFungibleToken.CollectionPublic, MetadataViews.ResolverCollection}>(
                FlowtyWrapped.CollectionPublicPath,
                target: FlowtyWrapped.CollectionStoragePath
            )
        }
    }
}