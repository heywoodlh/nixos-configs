''
  /* * Do not remove the @namespace line -- it's required for correct functioning */
  /* set default namespace to XUL */
  @namespace url("http://www.mozilla.org/keymaster/gatekeeper/there.is.only.xul");

  /* Remove Back button when there's nothing to go Back to */
  #back-button[disabled="true"] { display: none; }

  /* Remove Forward button when there's nothing to go Forward to */
  #forward-button[disabled="true"] { display: none; }

  /* Remove Home button (never use it) */
  #home-button { display: none; }

  .titlebar-spacer {
	    display: none !important;
  }

  /* Remove import bookmarks button */
  #import-button {
    display: none;
  }

  /* Remove bookmark toolbar */
  toolbarbutton.bookmark-item:not(.subviewbutton) {
    display: none;
  }

  /* Remove whitespace in toolbar */
  #nav-bar toolbarpaletteitem[id^="wrapper-customizableui-special-spring"], #nav-bar toolbarspring {
    display: none;
  }

  /* Hide dumb Firefox View button */
  #firefox-view-button {
    visibility: hidden;
  }

  /* Hide Firefox tab icon */
  .tab-icon-image {
    display: none;
  }
''
