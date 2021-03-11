public with sharing class SearchBooksController {
    
    @AuraEnabled(Cacheable = true)
    public static List<Book> fetchBooks(String searchTerm, String apiKey) {
        List<Book> lstBooks = new List<Book>();
        HttpRequest httpRequest = new HttpRequest();  
        
        httpRequest.setEndpoint('https://www.googleapis.com/books/v1/volumes?key='+apiKey+'&q='+ EncodingUtil.urlEncode(searchTerm, 'UTF-8'));
        httpRequest.setMethod('GET');
        String strResponse = null;
        try {  
            Http http = new Http();   
            HttpResponse httpResponse = http.send(httpRequest);  
            if (httpResponse.getStatusCode() == 200 ) { 
                strResponse = httpResponse.getBody();  
                JSONParser parser = JSON.createParser(strResponse);
                while (parser.nextToken() != null) {
                    if (parser.getCurrentToken() == JSONToken.START_ARRAY) {
                         while (parser.nextToken() != null) {
                            if (parser.getCurrentToken() == JSONToken.START_OBJECT) {
                                 Volume vol = (Volume)parser.readValueAs(Volume.class);
                                lstBooks.add(new Book(vol.id, vol.volumeInfo.title, vol.volumeInfo.publishedDate, vol.volumeInfo.previewLink, vol.volumeInfo.description));
                                parser.skipChildren();
                            }
                        }
                    }
                }
            } 
            else {  
                throw new CalloutException(httpResponse.getBody());  
            } 
        } 
        catch(Exception ex) {  
            throw ex;  
        }

        return lstBooks;
    }
    private class Volume {
        public String id;
        public VolumeInfo volumeInfo;
    }
    private class VolumeInfo {
        public String title;
        public String publishedDate;
        public String previewLink;
        public String description;
    }
    public class Book {
        @AuraEnabled
        public String bookId;
        @AuraEnabled
        public String title;
        @AuraEnabled
        public String publishedDate;
        @AuraEnabled
        public String previewLink;
        @AuraEnabled
        public String description;
        
        public Book(String bookId, String title, string publishedDate, string previewLink, String description) {
            this.bookId = bookId;
            this.title = title;
            this.publishedDate = publishedDate;
            this.previewLink = previewLink;
            this.description = description;
        }
    }
}