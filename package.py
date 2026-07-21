from frost_support import description
from frost_support import tool

# declare package description
class Description( description.Description ):

    # setup version we are building right now
    VERSION        = "3.16.4"
    VERSION_SUFFIX = "1"

    # setup tool build
    def __init__( self ):
        super().__init__(
            name           = "python",
            version        = Description.VERSION,
            version_suffix = Description.VERSION_SUFFIX
        )

# run as tool
if __name__ == "__main__":
    tool.run( Description() )
