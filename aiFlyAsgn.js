import { LightningElement, track, wire } from 'lwc';
import getOwnerInfo from '@salesforce/apex/LeadOppCtr.getOwnerInfo';

const columns = [
    { label: 'Owner', fieldName: 'owner', cellAttributes: { iconName: 'utility:user'} },
    { label: 'Total Leads', fieldName: 'noOfLeads', type: 'number' },
    { label: 'Total Opps.', fieldName: 'noOfOpps', type: 'number' },
    { label: 'Conv Rate', fieldName: 'convRate', type: 'percent', typeAttributes: {maximumFractionDigits: 2} },
    { label: 'Max Created Date (Opp)', fieldName: 'maxDate', type: 'date', typeAttributes: {day:"numeric",month:"numeric",year:"numeric"} },
    { label: 'Total Val (Opp)', fieldName: 'totalAmount', type: 'currency'},
];

export default class AiFlyAsgn extends LightningElement {
    @track startDate;
    @track endDate;
    columns = columns;
    @track data;
    @track error;
    @track loader = false;

    //@wire(getOwnerInfo)  

    handleDateChangeSd(event){
        this.loader = true;
        this.startDate = event.target.value;

        let callApex = this.validate();
        if(callApex!=0){
            getOwnerInfo({startDate : this.startDate, endDate: this.endDate})
            .then(result=>{
                this.loader = false;
                this.data = result;
            })
            .catch(error=>{
                this.loader = false;
                this.error = error;
            });
        }else{
            this.loader = false;
        }
    }
    handleDateChangeEd(event){
        this.loader = true;
        this.endDate = event.target.value;
        let callApex = this.validate();
        if(callApex!=0){
            getOwnerInfo({startDate : this.startDate, endDate: this.endDate})
            .then(result=>{
                this.loader = false;
                this.data = result;
            })
            .catch(error=>{
                this.loader = false;
                this.error = error;
            });
        }else{
            this.loader = false;
        }
    }

    validate(){
        console.log('Validate is runnung');
        let inputStartDate = this.template.querySelector(".startDateCmp");
        let inputEndDate = this.template.querySelector(".endDateCmp");
        let startDateValue = inputStartDate.value;
        let endDateValue = inputEndDate.value;

        var date1 = new Date(startDateValue);
        var date2 = new Date(endDateValue);

        if(!startDateValue){
            inputStartDate.setCustomValidity("Enter Start Date");
        }else if(!endDateValue){
            inputEndDate.setCustomValidity("Enter End Date");
        }else if(Math.ceil(Math.abs(date2.getTime() - date1.getTime()))/(1000*3600*24)>31){
            inputStartDate.setCustomValidity("Difference of dates should be less than 31.");
            inputEndDate.setCustomValidity("Difference of dates should be less than 31.");
        }else if(date2<date1){
            inputEndDate.setCustomValidity("End Date should be greater than start date.");
        }else{
            inputStartDate.setCustomValidity("");
            inputEndDate.setCustomValidity("");
        }
        inputEndDate.reportValidity();
        inputStartDate.reportValidity();
        return inputEndDate.reportValidity()&inputStartDate.reportValidity();
    }
}