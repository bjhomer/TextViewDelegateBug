A simple project demonstrating a bug in NSTextView as of 10.11.1. It has existed since at least OS X 10.10; I haven't tested beyond that.


## The bug

If you have multiple linked NSTextViews, removing any of them causes all notification-based delegate methods to be disabled for the first text view. This includes `-[NSTextViewDelegate textDidChange:]`. 