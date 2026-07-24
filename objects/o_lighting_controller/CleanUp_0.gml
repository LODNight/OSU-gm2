// ============================================================
// o_lighting_controller — CleanUp Event
// ============================================================

if (surface_exists(dark_surface))  surface_free(dark_surface);
if (surface_exists(light_surface)) surface_free(light_surface);
dark_surface  = -1;
light_surface = -1;

if (variable_global_exists("LightSources")) {
    ds_list_destroy(global.LightSources);
}