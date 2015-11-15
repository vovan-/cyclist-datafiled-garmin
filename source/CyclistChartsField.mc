using Toybox.Application as App;

//! @author vovan-
class CyclistChartsField extends App.AppBase {
    function getInitialView() {
        return [ new CyclistView() ];
    }
}