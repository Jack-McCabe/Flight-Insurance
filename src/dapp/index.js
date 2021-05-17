
import DOM from './dom';
import Contract from './contract';
import './flightsurety.css';


(async() => {

    let result = null;

    let contract = new Contract('localhost', () => {

        // Read transaction
        contract.isOperational((error, result) => {
            console.log(error,result);
            display('Operational Status', 'Check if contract is operational', [ { label: 'Operational Status', error: error, value: result} ]);
        });
    

        // User-submitted transaction
        DOM.elid('submit-oracle').addEventListener('click', () => {
            let flightNumber = DOM.elid('flight-number').value;
            let flightCity = DOM.elid('flight-city').value;
            let flightTime = DOM.elid('flight-time').value; 
            // Write transaction
            contract.registerFlight(flightNumber, flightCity, flightTime,(error, result) => {
                display('Oracles', 'Trigger oracles', 'someting' [{ label: 'Register Flight', error: error, value: result.flightNumber + ' ' + flightCity+ ' ' + flightTime + ' ' + result.timestamp }]);
           console.log("got here");
            });
        });

        DOM.elid('submit-airline').addEventListener('click', () => {

            let airline = DOM.elid('airline').value; //this will be the airline address passed to the function
            // Write transaction
            contract.registerAirline(airline, (error, result) => {
                display('Oracles', 'Trigger oracles', [{ label: 'Submit Airline', error: error, value: result }]);
            });
            // contract.fetchFlightStatus(airline, (error, result) => {
            //     display('Oracles', 'Trigger oracles', [{ label: 'Fetch Flight Status', error: error, value: result.flight + ' ' + result.timestamp }]);
            // });
        });
    
    });
    

})();


function display(title, description, results) {
    let displayDiv = DOM.elid("display-wrapper");
    let section = DOM.section();
    section.appendChild(DOM.h2(title));
    section.appendChild(DOM.h5(description));
    results.map((result) => {
        let row = section.appendChild(DOM.div({className:'row'}));
        row.appendChild(DOM.div({className: 'col-sm-4 field'}, result.label));
        row.appendChild(DOM.div({className: 'col-sm-8 field-value'}, result.error ? String(result.error) : String(result.value)));
        section.appendChild(row);
    })
    displayDiv.append(section);

}







