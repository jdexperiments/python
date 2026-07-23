from frost_support import description
from frost_support import tool

# declare package description
class Description( description.Description ):

    # setup build
    def __init__( self ):
        super().__init__(
            name           = "python",
            version        = "3.13.14",
            version_suffix = "1"
        )

# run as tool
if __name__ == "__main__":
    tool.run( Description() )
