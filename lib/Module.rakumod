use v6.d;
use Base;
use Variable;
use Statement;
use Routine;
use ProgramUnit;

# Module class (corresponding to TModule)
class Module is ProgramUnit is export {
    has IdTable $.share-var-table .= new;
    has IdTable $.share-sub-table .= new;
    
    method new(Str $name, Str $kind = 'M') {
        self.bless: :$name, :$kind;
    }
    
    method run-module() {
        self.routine-body();
    }
    
    method run-main() {
        self.routine-body();
    }
    
    method var-tables-rebuild() {
        callsame();
        $!share-var-table = IdTable.new;
        $!share-sub-table = IdTable.new;
    }
}
