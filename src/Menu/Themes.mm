#include "Themes.h"
#include "imgui.h"

namespace Themes {

static const char *kNames[] = {"Dark Purple", "Ocean Blue", "Blood Red", "Matrix Green"};

int Count() {
    return 4;
}

const char *Name(int themeIndex) {
    if (themeIndex < 0 || themeIndex >= Count()) return kNames[0];
    return kNames[themeIndex];
}

static void ApplyDarkPurple(ImGuiStyle &s) {
    ImVec4 *c = s.Colors;
    c[ImGuiCol_WindowBg] = {0.08f, 0.06f, 0.12f, 0.95f};
    c[ImGuiCol_Header] = {0.35f, 0.15f, 0.55f, 0.8f};
    c[ImGuiCol_HeaderHovered] = {0.45f, 0.20f, 0.65f, 1.f};
    c[ImGuiCol_HeaderActive] = {0.55f, 0.25f, 0.75f, 1.f};
    c[ImGuiCol_Button] = {0.35f, 0.15f, 0.55f, 0.8f};
    c[ImGuiCol_ButtonHovered] = {0.45f, 0.20f, 0.65f, 1.f};
    c[ImGuiCol_ButtonActive] = {0.55f, 0.25f, 0.75f, 1.f};
    c[ImGuiCol_FrameBg] = {0.15f, 0.10f, 0.22f, 0.8f};
    c[ImGuiCol_CheckMark] = {0.75f, 0.45f, 1.f, 1.f};
    c[ImGuiCol_SliderGrab] = {0.65f, 0.35f, 0.95f, 1.f};
    c[ImGuiCol_TitleBgActive] = {0.25f, 0.10f, 0.40f, 1.f};
}

static void ApplyOceanBlue(ImGuiStyle &s) {
    ImVec4 *c = s.Colors;
    c[ImGuiCol_WindowBg] = {0.05f, 0.10f, 0.18f, 0.95f};
    c[ImGuiCol_Header] = {0.10f, 0.35f, 0.65f, 0.8f};
    c[ImGuiCol_Button] = {0.10f, 0.35f, 0.65f, 0.8f};
    c[ImGuiCol_CheckMark] = {0.30f, 0.70f, 1.f, 1.f};
}

static void ApplyBloodRed(ImGuiStyle &s) {
    ImVec4 *c = s.Colors;
    c[ImGuiCol_WindowBg] = {0.12f, 0.05f, 0.05f, 0.95f};
    c[ImGuiCol_Header] = {0.55f, 0.10f, 0.10f, 0.8f};
    c[ImGuiCol_Button] = {0.55f, 0.10f, 0.10f, 0.8f};
    c[ImGuiCol_CheckMark] = {1.f, 0.30f, 0.30f, 1.f};
}

static void ApplyMatrixGreen(ImGuiStyle &s) {
    ImVec4 *c = s.Colors;
    c[ImGuiCol_WindowBg] = {0.02f, 0.08f, 0.04f, 0.95f};
    c[ImGuiCol_Header] = {0.05f, 0.35f, 0.12f, 0.8f};
    c[ImGuiCol_Button] = {0.05f, 0.35f, 0.12f, 0.8f};
    c[ImGuiCol_CheckMark] = {0.20f, 1.f, 0.35f, 1.f};
}

void Apply(int themeIndex, ImGuiStyle &style) {
    ImGui::StyleColorsDark();
    style.WindowRounding = 8.f;
    style.FrameRounding = 4.f;
    style.GrabRounding = 4.f;
    style.ScrollbarRounding = 6.f;
    switch (themeIndex) {
        case 1: ApplyOceanBlue(style); break;
        case 2: ApplyBloodRed(style); break;
        case 3: ApplyMatrixGreen(style); break;
        default: ApplyDarkPurple(style); break;
    }
}

} // namespace Themes
