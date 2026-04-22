use v6.d;
use Base;
use Variable;
use Statement;
use Routine;

# Program unit class (corresponding to TProgramUnit)
class ProgramUnit is export is Routine {
    has Int $.line-number = 0;
    has $.parent; # Untyped to avoid circular dependency
    has IdTable $.external-var-table .= new;
    has IdTable $.external-sub-table .= new;
    has @.data-sequence;
    has @.image-list;
    has @.trace-list;
    has Precision $.arithmetic = PrecisionNormal;
    has Int $.array-base = 1;
    has Bool $.angle-degrees = False;
    has Bool $.character-byte = False;
    has Bool $.debug = False;
    has OptionAppearance $.option-arithmetic = ApNone;
    has OptionAppearance $.option-angle = ApNone;
    has OptionAppearance $.option-base = ApNone;
    has OptionAppearance $.option-collate = ApNone;
    has Bool $.dim-appeared = False;
    
    method new(Str $name, Str $kind, Int $maxlen = 0, $parent?) {
        self.bless: :$name, :$kind, :$parent;
    }
    
    method channel-sub(Int $ch, Bool $can-insert) {
        # Return text device for channel
    }
    
    method channel(Int $ch) {
        # Return text device for channel
    }
    
    method open-printer(Int $ch) {
        # Open printer on channel
    }
    
    method open(Int $ch, Str $filename, AccessMode $am, RecordType $rc, OrganizationType $og, Int $len) {
        # Open file
    }
    
    method close(Int $ch) {
        # Close channel
    }
    
    method routine-body() {
        # Execute program unit body - call parent implementation
        callsame();
    }
    
    method var-tables-rebuild() {
        # Call parent implementation first
        callsame();
        # Then rebuild our additional tables
        $!external-var-table = IdTable.new;
        $!external-sub-table = IdTable.new;
    }
}
