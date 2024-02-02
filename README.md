# Deploy-Moodle-with-Salt-SSH

## Overview
This project automates the deployment of the Moodle web application using salt-ssh mode, eliminating the need to set up a master and minions. Additionally, it provides instructions on setting up a block plugin with a form in Moodle.

## Prerequisites
Before starting the deployment, make sure you have the following prerequisites:

- SSH connection to the VM without any issues
- Salt-SSH installed
- Domain resolved to the IP address of the VM

## Quick Start
1. Clone the Repository  
`git clone https://github.com/HerrSun/Deploy-Moodle-with-Salt-SSH.git`
3. Write down server info into `roster` file
2. Modify the parameters enclosed by `<>` in pillar folder
4. Aplly Salt state
 `salt-ssh '*' state.apply --roster-file roster`

## Build block in moodle with form
In the "blocks" folder, you will find two subfolders: "<new_block_name>." and "<new_block_name>._form." The "<new_block_name>." folder contains the code for a block that displays Google search results for "Moodle Block." The "<new_block_name>._form" folder contains the code for a block with a form that allows users to input keywords and then view the corresponding Google search results.

### Workflow for Building a New Block
1. Install pluginskel
    - Clone the pluginskel repository:  
    `git clone https://github.com/mudrd8mz/moodle-tool_pluginskel <moodle_path>/admin/tool/pluginskel`
    - Update the database:  
    `php <moodle_path>/admin/cli/upgrade.php`
    - Create a new YAML file based on the `example.yml` template in folder  
    `<moodle_path>/admin/tool/pluginskel/cli`.
    - Generate the necessary files:  
    `php generate.php block_<new_block_name>..yml`
2. Modify Block Functionality

    Modify the code located at `<moodle_path>/blocks/<new_block_name>.`.

3. Add CSS Styling

    Create a `styles.css` file in the root folder of the block to enhance its appearance.
4. Purge Cache

    Purge the cache to display the changes.
    `php <moodle_path>/admin/cli/purge_caches.php`
5. For Blocks with Forms

    - Add new form classes at
    `<moodle_path>/blocks/<new_block_name>/classed/form/myform.php`
    - Create an mform instance inside the main block YAML file.