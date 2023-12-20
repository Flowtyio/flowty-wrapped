import "NonFungibleToken"
import "FlowtyWrapped"
import "MetadataViews"

transaction {

    prepare(signer: AuthAccount) {

        // Return early if the account already stores a FlowtyWrapped Collection
        if signer.borrow<&FlowtyWrapped.Collection>(from: FlowtyWrapped.CollectionStoragePath) == nil {
            // Create a new FlowtyWrapped Collection and put it in storage
            signer.save(
                <-FlowtyWrapped.createEmptyCollection(),
                to: FlowtyWrapped.CollectionStoragePath
            )

            // Create a public capability to the Collection that only exposes
            // the balance field through the Balance interface
            signer.link<&FlowtyWrapped.Collection{NonFungibleToken.CollectionPublic, MetadataViews.ResolverCollection}>(
                FlowtyWrapped.CollectionPublicPath,
                target: FlowtyWrapped.CollectionStoragePath
            )
        }
    }
}