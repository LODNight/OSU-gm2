if (variable_instance_exists(id, "tutorialSpawner") && instance_exists(tutorialSpawner)) {
    with (tutorialSpawner) instance_destroy();
}
