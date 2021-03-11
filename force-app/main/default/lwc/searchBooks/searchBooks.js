import { LightningElement, track } from 'lwc';
import fetchBooks from '@salesforce/apex/SearchBooksController.fetchBooks';

export default class SearchBooks extends LightningElement {
    apikey='';
    resultBooks;
    queryTerm;
    errorMessage;

    handleApiKeyChange(event) {
        this.apikey = event.target.value;
    }

    handleQueryTermChange(event) {
        this.queryTerm = event.detail.value;
    }

    handleSearch() {  
        if(this.apikey=='') {
            this.errorMessage = 'Please enter an api key';
            this.resultBooks = null;
            return;
        }

        if(!this.queryTerm) {
            this.errorMessage = 'Please enter a term to search';
            this.resultBooks = null;
            return;
        }

        fetchBooks({searchTerm : this.queryTerm, apiKey: this.apikey})
        .then(result => {
            this.resultBooks = result;
            this.errorMessage=null;
        })
        .catch(error => {
            this.resultBooks = null;
            if(error) {
                this.errorMessage = error.body?.message;
            }
        }) 
    }
  
}