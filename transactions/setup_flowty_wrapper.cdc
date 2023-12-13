import "NonFungibleToken"
import "FlowtyWrapper"
import "MetadataViews"

transaction {

    prepare(signer: AuthAccount) {

        // Return early if the account already stores a ExampleToken Vault
        if signer.borrow<&FlowtyWrapper.Collection>(from: FlowtyWrapper.CollectionStoragePath) == nil {
            // Create a new ExampleToken Vault and put it in storage
            signer.save(
                <-FlowtyWrapper.createEmptyCollection(),
                to: FlowtyWrapper.CollectionStoragePath
            )

            // Create a public capability to the Vault that only exposes
            // the balance field through the Balance interface
            signer.link<&FlowtyWrapper.Collection{NonFungibleToken.CollectionPublic, MetadataViews.ResolverCollection}>(
                FlowtyWrapper.CollectionPublicPath,
                target: FlowtyWrapper.CollectionStoragePath
            )
        }
    }
}