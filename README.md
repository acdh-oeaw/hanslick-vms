# Hanslick VMS

This git repository currently contains test data of the [FWF edition project P 30554](https://pf.fwf.ac.at/project_pdfs/pdf_abstracts/p30554d.pdf) on Eduard Hanslick: „Vom Musikalisch-Schönen. Ein Beitrag zur Revision der Aesthetik der Tonkunst.“

Provided by Alexander and Meike Wilfing, Sept 2018

* 102_02_tei-simple contains the "resulting" TEI data to be manually edited

Cf. https://redmine.acdh.oeaw.ac.at/issues/17183

## Setup

In order to build the HTML output of the data, the TEI-C XSLT suite is needed.  

* Clone the TEI-C Stylesheets from https://github.com/TEIC/Stylesheets  
* Adjust the import statement in `tei2html.xsl` to point to it.

## Rebuilding the data

### Building the basic TEI documents

**BEWARE** THIS REMOVES ANY MANUAL EDITS on the TEI documents

* run *DOCX TEI P5* transformation scenario on 001_src
* copy resulting XML to 102_01_tei-full
* rename "media" folder containing images to the number of the edition (01–10)
* convert tif images to jpg (e.g. using `convert`)
* run *simplify & upconvert* transformation scenario on 102_01_tei-full

The preliminary TEI documents are placed into 102_02_tei-simple where they should be further corrected/edited.

### Building the paragraph diffs

* run the *comp* transformation scenario
* diff TEI documents will be placed into 102_05_comp

### Building index docments

currently only a person index is implemented preliminarily, more to follow

* run the *index_persons* transformation scenario
* index TEI documents will be placed into 102_04_indexes

NB: if a `<persName>` element contains a `@key` attribute this will be used as the index entry of the occurence in question.

## (Re)building the website

* run the *TEI P5 XHTML* transformation scenario on
  * 102_02_tei-simple
  * 102_04_indexes
  * 102_05_comp
  * 102_06_paratexts

The transcformation consists in the following steps:

* first ,`082_scripts_xsl/tei2html.xsl` is applied to the TEI input which overrides some specific templates from the TEI stylesheets
* a postporcessing stylesheet, `082_scripts_xsl/xhtmlPostPro.xsl` is applied on the result which injects necessary CSS and JS references as well as the basic menu structure.    

NB The TEI to HTML build process is only a preliminary solution and should be revisited anytime soon. 

## Deployment 

After committing and pushing, all data inside of the `public` directory will be automatically deployed by the gitlab CI pipeline in place.
