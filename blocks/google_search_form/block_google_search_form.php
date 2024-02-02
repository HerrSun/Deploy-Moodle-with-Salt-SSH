<?php
// This file is part of Moodle - https://moodle.org/
//
// Moodle is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// Moodle is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with Moodle.  If not, see <https://www.gnu.org/licenses/>.

/**
 * Block google_search is defined here.
 *
 * @package     block_google_search_form
 * @copyright   2024 Yi Sun <sunyi.chn@outlook.com>
 * @license     https://www.gnu.org/copyleft/gpl.html GNU GPL v3 or later
 */
require_once('classes/form/google_search_input_form.php');
class block_google_search_form extends block_base {
    public function init() {
        $this->title = get_string('pluginname', 'block_google_search_form');
    }

    public function get_content() {
        if ($this->content !== null) {
            return $this->content;
        }

        $mform = new google_search_input_form();

        $this->content = new stdClass;
        $this->content->text = ''; // Initialize text content
        $this->content->footer = '';

        if ($fromform = $mform->get_data()) {
            // Handle form submission
            $this->content->text .= 'Submitted content: ' . s($fromform->search);
            $searchQueryRaw = $fromform->search;
        } else {
            // Display the form
            $this->content->text .= html_writer::tag('p', 'Enter your search query:', array('class' => 'search-instruction'));
            $this->content->text .= $mform->render();
        }
        if ($searchQueryRaw) {
            $apiResponse = $this->get_api_data($searchQueryRaw);

            // Check if API response is valid and parse the results
            if ($apiResponse) {
                $data = json_decode($apiResponse, true);
                if (!empty($data['items'])) {
                    $results = array_slice($data['items'], 0, 3); // Get top three results
                    $this->content->text = $this->format_results($results);
                } else {
                    $this->content->text = 'No results found.';
                }
            } else {
                $this->content->text = 'Error retrieving data from the API.';
            }
        }

        return $this->content;
    }

    /**
     * Makes a cURL request to the Google Custom Search JSON API and returns the response.
     *
     * @return string|false The API response or false on failure.
     */
    private function get_api_data($serchQueryRaw) {
        $apiKey = '<replace_your_own_API_KEY>'; // Replace with your API key
        $cx = '<replace_your_own_ID>'; // Replace with your Custom Search Engine ID
        $searchQuery = urlencode($serchQueryRaw); // Replace with your search query

        $url = "https://www.googleapis.com/customsearch/v1?key={$apiKey}&cx={$cx}&q={$searchQuery}";

        $curl = curl_init();
        curl_setopt($curl, CURLOPT_URL, $url);
        curl_setopt($curl, CURLOPT_RETURNTRANSFER, true);
        curl_setopt($curl, CURLOPT_FOLLOWLOCATION, true);

        $response = curl_exec($curl);
        $err = curl_error($curl);

        curl_close($curl);

        if ($err) {
            return false; // Handle the error as needed
        }
        return $response;
    }

    /**
     * Formats the search results for display.
     *
     * @param array $results The search results.
     * @return string Formatted search results.
     */
    private function format_results($results) {
        $output = '<ul>';
        foreach ($results as $result) {
            $output .= '<li>';
            $output .= '<a href="' . htmlspecialchars($result['link']) . '"><strong>' . htmlspecialchars($result['title']) . '</strong></a><br>';
            $output .= '<span class="snippet">' . htmlspecialchars($result['snippet']) . '</span>';
            $output .= '</li>';
        }
        $output .= '</ul>';
        return $output;
    }

    public function specialization() {

        // Load user defined title and make sure it's never empty.
        if (empty($this->config->title)) {
            $this->title = get_string('pluginname', 'block_google_search_form');
        } else {
            $this->title = $this->config->title;
        }
    }

    /**
     * Enables global configuration of the block in settings.php.
     *
     * @return bool True if the global configuration is enabled.
     */
    public function has_config() {
        return true;
    }

    /**
     * Sets the applicable formats for the block.
     *
     * @return string[] Array of pages and permissions.
     */
    public function applicable_formats() {
        return array(
            'all' => true,
            'course-view' => true,
            'course-view-social' => false,
        );
    }
}