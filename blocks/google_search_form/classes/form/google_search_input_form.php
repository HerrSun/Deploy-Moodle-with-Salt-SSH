<?php
require_once("$CFG->libdir/formslib.php");

class google_search_input_form extends moodleform {
    // Add elements to form
    public function definition() {
        $mform = $this->_form; // Don't forget the underscore!

        // Search field
        $mform->addElement('text', 'search', get_string('search', 'block_google_search_form'));
        $mform->setType('search', PARAM_NOTAGS);

        // Add a submit button
        $mform->addElement('submit', 'submitbutton', get_string('submit', 'block_google_search_form'));
    }
}
