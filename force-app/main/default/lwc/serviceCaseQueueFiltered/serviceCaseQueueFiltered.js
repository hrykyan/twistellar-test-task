import updateStatus from "@salesforce/apex/ServiceCaseQueueService.updateStatus";
import getUserCases from "@salesforce/apex/ServiceCaseQueueService.getUserCases";
import { getObjectInfo } from "lightning/uiObjectInfoApi";
import { getPicklistValues } from "lightning/uiObjectInfoApi";
import CASE_OBJECT from "@salesforce/schema/Case";
import STATUS_FIELD from "@salesforce/schema/Case.Status";

import { LightningElement, api, wire, track } from "lwc";
import { NavigationMixin } from "lightning/navigation";
import { refreshApex } from "@salesforce/apex";
import { ShowToastEvent } from "lightning/platformShowToastEvent";

export default class ServiceCaseQueueFiltered extends NavigationMixin(LightningElement) {
  @api cases = [];
  loaded = true;
  value = "";
  valuesOfPicklist = [];
  currentId = "";
  refreshIsCalled = false;
  caseIdInStatusField;

  @wire(getObjectInfo, { objectApiName: CASE_OBJECT })caseMetadata;

  @wire(getPicklistValues,
    {
      recordTypeId: "$caseMetadata.data.defaultRecordTypeId",
      fieldApiName: STATUS_FIELD
    }
  ) statusPicklist({ data, error }) {
    if (data) {
      this.valuesOfPicklist = data.values;
      console.log(this.valuesOfPicklist);
    } else if (error) {
      this.error = error;
    }
  };

  @wire(getUserCases) getCases(result) {
    console.log("Called Cases");
    this.refreshTable = result;
    const { error, data } = result;
    if (data) {
      this.cases = data;
    } else if (error) {
      this.error = error;
    }
  }

  handleLoad() {
    this.changeSpinnerStatus();
    getUserCases()
      .then(result => {
        this.cases = result;
        setTimeout(() => {
          this.changeSpinnerStatus();
        }, 2000);

      })
      .catch(error => {
        this.error = error;
      });
  }

  handleGetPicklistId(event) {
    if (event.target.id !== "") {
      this.caseIdInStatusField = event.target.id.slice(0, event.currentTarget.id.length - 3);
    }
  }

  picklistChange(event) {
    this.value = event.detail.value;
    console.log(event.detail.value);

    updateStatus({ status: this.value, caseId: this.caseIdInStatusField })
      .then(result => {
        this.refreshPage();
        this.showToastSuccess();
      })
      .catch(error => {
        this.showToastError();
      });
  }

  changeSpinnerStatus() {
    console.log("changeSpinnerStatus");
    this.loaded = !this.loaded;
  }

  refreshPage() {
    console.log("refresh");
    this.refreshIsCalled = true;
    return refreshApex(this.refreshTable);
  }

  navigateToCase(event) {
    console.log(event.currentTarget.id);
    this.currentId = event.currentTarget.id.slice(0, event.currentTarget.id.length - 3);
    console.log(this.currentId);
    this[NavigationMixin.Navigate]({
      type: "standard__recordPage",
      attributes: {
        recordId: this.currentId,
        objectApiName: "Case",
        actionName: "view"
      }
    });
  }

  showToastSuccess() {
    const event = new ShowToastEvent({
      title: "Success",
      message:
        "All right!",
      variant: "success"
    });
    this.dispatchEvent(event);
  }

  showToastError() {
    const event = new ShowToastEvent({
      title: "Error",
      message:
        "Something went wrong...",
      variant: "error"
    });
    this.dispatchEvent(event);
  }


}
