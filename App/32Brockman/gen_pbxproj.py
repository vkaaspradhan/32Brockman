import pathlib, os, uuid

base = pathlib.Path(".")
swift_files = []
for root, dirs, files in os.walk("."):
    dirs[:] = [d for d in dirs if not d.startswith(".")]
    for f in files:
        if f.endswith(".swift"):
            full = pathlib.Path(root) / f
            rel = full.relative_to(".").as_posix()
            swift_files.append(rel)
swift_files.sort()

def nid():
    return uuid.uuid4().hex[:24].upper()

fileref_ids = {rel: nid() for rel in swift_files}
buildfile_ids = {rel: nid() for rel in swift_files}
infopkg_id = nid()
appref_id = nid()
root_id = nid()
src_group_id = nid()
models_group_id = nid()
services_group_id = nid()
views_group_id = nid()
products_group_id = nid()
sources_phase_id = nid()
frameworks_phase_id = nid()
resources_phase_id = nid()
target_configlist_id = nid()
project_configlist_id = nid()
target_id = nid()
project_id = nid()
cfg_project_debug = nid(); cfg_project_release = nid()
cfg_target_debug = nid(); cfg_target_release = nid()

models_files = sorted([r for r in swift_files if r.startswith("Models/")])
services_files = sorted([r for r in swift_files if r.startswith("Services/")])
views_files = sorted([r for r in swift_files if r.startswith("Views/")])
top_files = [r for r in swift_files if "/" not in r]

def name_of(rel):
    return rel.split('/')[-1]

objects = []

for rel in swift_files:
    objects.append(f"\t\t{buildfile_ids[rel]} /* {name_of(rel)} in Sources */ = {{isa = PBXBuildFile; fileRef = {fileref_ids[rel]} /* {name_of(rel)} */; }};")
for rel in swift_files:
    objects.append(f"\t\t{fileref_ids[rel]} /* {name_of(rel)} */ = {{isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = {name_of(rel)}; sourceTree = \"<group>\"; }};")
objects.append(f"\t\t{infopkg_id} /* Info.plist */ = {{isa = PBXFileReference; lastKnownFileType = text.plist.xml; path = Info.plist; sourceTree = \"<group>\"; }};")
objects.append(f"\t\t{appref_id} /* 32Brockman.app */ = {{isa = PBXFileReference; explicitFileType = wrapper.application; includeInIndex = 0; path = 32Brockman.app; sourceTree = BUILT_PRODUCTS_DIR; }};")

objects.append(f"\t\t{frameworks_phase_id} /* Frameworks */ = {{isa = PBXFrameworksBuildPhase; buildActionMask = 2147483647; files = (\n\t\t); name = Frameworks; runOnlyForDeploymentPostprocessing = 0; }};")
objects.append(f"\t\t{resources_phase_id} /* Resources */ = {{isa = PBXResourcesBuildPhase; buildActionMask = 2147483647; files = (\n\t\t); name = Resources; runOnlyForDeploymentPostprocessing = 0; }};")
src_lines = ",\n".join(f"\t\t\t\t{buildfile_ids[rel]} /* {name_of(rel)} in Sources */" for rel in swift_files)
objects.append(f"\t\t{sources_phase_id} /* Sources */ = {{isa = PBXSourcesBuildPhase; buildActionMask = 2147483647; files = (\n{src_lines}\n\t\t); name = Sources; runOnlyForDeploymentPostprocessing = 0; }};")

root_children = ",\n".join([
    f"\t\t\t\t{src_group_id} /* 32Brockman */",
    f"\t\t\t\t{products_group_id} /* Products */",
])
objects.append(f"\t\t{root_id} = {{isa = PBXGroup; children = (\n{root_children}\n\t\t); sourceTree = \"<group>\"; }};")

src_children = []
for r in top_files:
    src_children.append(f"\t\t\t\t{fileref_ids[r]} /* {name_of(r)} */")
src_children.append(f"\t\t\t\t{models_group_id} /* Models */")
src_children.append(f"\t\t\t\t{services_group_id} /* Services */")
src_children.append(f"\t\t\t\t{views_group_id} /* Views */")
src_children.append(f"\t\t\t\t{infopkg_id} /* Info.plist */")
objects.append(f"\t\t{src_group_id} /* 32Brockman */ = {{isa = PBXGroup; children = (\n" + "\n".join(src_children) + f"\n\t\t); path = 32Brockman; sourceTree = \"<group>\"; }};")

def subgroup(gid, nm, files):
    ch = ",\n".join(f"\t\t\t\t{fileref_ids[r]} /* {name_of(r)} */" for r in files)
    return f"\t\t{gid} /* {nm} */ = {{isa = PBXGroup; children = (\n{ch}\n\t\t); path = {nm}; sourceTree = \"<group>\"; }};"

objects.append(subgroup(models_group_id, "Models", models_files))
objects.append(subgroup(services_group_id, "Services", services_files))
objects.append(subgroup(views_group_id, "Views", views_files))
objects.append(f"\t\t{products_group_id} /* Products */ = {{isa = PBXGroup; children = (\n\t\t\t\t{appref_id} /* 32Brockman.app */\n\t\t); name = Products; sourceTree = \"<group>\"; }};")

objects.append(f"\t\t{target_id} /* 32Brockman */ = {{isa = PBXNativeTarget; buildConfigurationList = {target_configlist_id} /* Build configuration list for PBXNativeTarget \"32Brockman\" */; buildPhases = (\n\t\t\t\t{sources_phase_id} /* Sources */,\n\t\t\t\t{frameworks_phase_id} /* Frameworks */,\n\t\t\t\t{resources_phase_id} /* Resources */,\n\t\t); buildRules = (\n\t\t); dependencies = (\n\t\t); name = 32Brockman; productName = 32Brockman; productReference = {appref_id} /* 32Brockman.app */; productType = \"com.apple.product-type.application\"; }};")

objects.append(f"\t\t{project_id} /* Project object */ = {{isa = PBXProject; attributes = {{\n\t\t\t\tLastSwiftUpdateCheck = 1500;\n\t\t\t\tLastUpgradeCheck = 1500;\n\t\t\t\tTargetAttributes = {{\n\t\t\t\t\t{target_id} = {{\n\t\t\t\t\t\tCreatedOnToolsVersion = 15.0;\n\t\t\t\t\t}};\n\t\t\t\t}};\n\t\t\t}}; buildConfigurationList = {project_configlist_id} /* Build configuration list for PBXProject \"32Brockman\" */; compatibilityVersion = \"Xcode 14.0\"; developmentRegion = en; hasScannedForEncodings = 0; knownRegions = (\n\t\t\t\ten,\n\t\t\t\tBase,\n\t\t\t); mainGroup = {root_id}; productRefGroup = {products_group_id} /* Products */; projectDirPath = \"\"; projectRoot = \"\"; targets = (\n\t\t\t\t{target_id} /* 32Brockman */,\n\t\t); }};")

project_debug_settings = """\t\t\t\tALWAYS_SEARCH_USER_PATHS = NO;
\t\t\t\tCLANG_ANALYZER_NONNULL = YES;
\t\t\t\tCLANG_ANALYZER_NUMBER_OBJECT_CONVERSION = YES_AGGRESSIVE;
\t\t\t\tCLANG_CXX_LANGUAGE_STANDARD = "gnu++20";
\t\t\t\tCLANG_ENABLE_MODULES = YES;
\t\t\t\tCLANG_ENABLE_OBJC_ARC = YES;
\t\t\t\tCLANG_ENABLE_OBJC_WEAK = YES;
\t\t\t\tCLANG_WARN_BOOL_CONVERSION = YES;
\t\t\t\tCLANG_WARN_COMMA = YES;
\t\t\t\tCLANG_WARN_CONSTANT_CONVERSION = YES;
\t\t\t\tCLANG_WARN_DEPRECATED_OBJC_IMPLEMENTATIONS = YES;
\t\t\t\tCLANG_WARN_DIRECT_OBJC_ISA_USAGE = YES_ERROR;
\t\t\t\tCLANG_WARN_DOCUMENTATION_COMMENTS = YES;
\t\t\t\tCLANG_WARN_EMPTY_BODY = YES;
\t\t\t\tCLANG_WARN_ENUM_CONVERSION = YES;
\t\t\t\tCLANG_WARN_INFINITE_RECURSION = YES;
\t\t\t\tCLANG_WARN_INT_CONVERSION = YES;
\t\t\t\tCLANG_WARN_NON_LITERAL_NULL_CONVERSION = YES;
\t\t\t\tCLANG_WARN_OBJC_IMPLICIT_RETAIN_SELF = YES;
\t\t\t\tCLANG_WARN_OBJC_LITERAL_CONVERSION = YES;
\t\t\t\tCLANG_WARN_OBJC_ROOT_CLASS = YES_ERROR;
\t\t\t\tCLANG_WARN_QUOTED_INCLUDE_IN_FRAMEWORK_HEADER = YES;
\t\t\t\tCLANG_WARN_RANGE_LOOP_ANALYSIS = YES;
\t\t\t\tCLANG_WARN_STRICT_PROTOTYPES = YES;
\t\t\t\tCLANG_WARN_SUSPICIOUS_MOVE = YES;
\t\t\t\tCLANG_WARN_UNGUARDED_AVAILABILITY = YES_AGGRESSIVE;
\t\t\t\tCLANG_WARN_UNREACHABLE_CODE = YES;
\t\t\t\tCLANG_WARN__DUPLICATE_METHOD_MATCH = YES;
\t\t\t\tCOPY_PHASE_STRIP = NO;
\t\t\t\tDEBUG_INFORMATION_FORMAT = dwarf;
\t\t\t\tENABLE_STRICT_OBJC_MSGSEND = YES;
\t\t\t\tENABLE_TESTABILITY = YES;
\t\t\t\tGCC_C_LANGUAGE_STANDARD = gnu17;
\t\t\t\tGCC_DYNAMIC_NO_PIC = NO;
\t\t\t\tGCC_NO_COMMON_BLOCKS = YES;
\t\t\t\tGCC_OPTIMIZATION_LEVEL = 0;
\t\t\t\tGCC_PREPROCESSOR_DEFINITIONS = (
\t\t\t\t\t"DEBUG=1",
\t\t\t\t\t"$(inherited)",
\t\t\t\t);
\t\t\t\tGCC_WARN_64_TO_32_BIT_CONVERSION = YES;
\t\t\t\tGCC_WARN_ABOUT_RETURN_TYPE = YES_ERROR;
\t\t\t\tGCC_WARN_UNDECLARED_SELECTOR = YES;
\t\t\t\tGCC_WARN_UNINITIALIZED_AUTOS = YES_AGGRESSIVE;
\t\t\t\tGCC_WARN_UNUSED_FUNCTION = YES;
\t\t\t\tGCC_WARN_UNUSED_VARIABLE = YES;
\t\t\t\tMTL_ENABLE_DEBUG_INFO = INCLUDE_SOURCE;
\t\t\t\tMTL_FAST_MATH = YES;
\t\t\t\tONLY_ACTIVE_ARCH = YES;
\t\t\t\tSWIFT_ACTIVE_COMPILATION_CONDITIONS = DEBUG;
\t\t\t\tSWIFT_OPTIMIZATION_LEVEL = "-Onone";"""

project_release_settings = (project_debug_settings
    .replace('DEBUG_INFORMATION_FORMAT = dwarf;', 'DEBUG_INFORMATION_FORMAT = "dwarf-with-dsym";')
    .replace('COPY_PHASE_STRIP = NO;', 'COPY_PHASE_STRIP = YES;')
    .replace('GCC_DYNAMIC_NO_PIC = NO;', 'GCC_DYNAMIC_NO_PIC = YES;')
    .replace('GCC_OPTIMIZATION_LEVEL = 0;', 'GCC_OPTIMIZATION_LEVEL = s;')
    .replace('MTL_ENABLE_DEBUG_INFO = INCLUDE_SOURCE;', 'MTL_ENABLE_DEBUG_INFO = NO;')
    .replace('ONLY_ACTIVE_ARCH = YES;', 'ONLY_ACTIVE_ARCH = NO;')
    .replace('SWIFT_ACTIVE_COMPILATION_CONDITIONS = DEBUG;', 'SWIFT_ACTIVE_COMPILATION_CONDITIONS = "";')
    .replace('SWIFT_OPTIMIZATION_LEVEL = "-Onone";', 'SWIFT_OPTIMIZATION_LEVEL = "-O";'))

target_debug_settings = """\t\t\t\tASSETCATALOG_COMPILER_GENERATE_ASSETCATALOGS = YES;
\t\t\t\tCODE_SIGN_STYLE = Automatic;
\t\t\t\tCURRENT_PROJECT_VERSION = 1;
\t\t\t\tENABLE_BITCODE = NO;
\t\t\t\tGENERATE_INFOPLIST_FILE = NO;
\t\t\t\tINFOPLIST_FILE = 32Brockman/Info.plist;
\t\t\t\tINFOPLIST_KEY_UIApplicationSupportsIndirectInputEvents = YES;
\t\t\t\tLD_RUNPATH_SEARCH_PATHS = (
\t\t\t\t\t"$(inherited)",
\t\t\t\t\t"@executable_path/Frameworks",
\t\t\t\t);
\t\t\t\tMARKETING_VERSION = 1.0;
\t\t\t\tPRODUCT_BUNDLE_IDENTIFIER = com.brockman.app;
\t\t\t\tPRODUCT_NAME = "$(TARGET_NAME)";
\t\t\t\tSWIFT_EMIT_LOC_STRINGS = YES;
\t\t\t\tSWIFT_VERSION = 5.0;
\t\t\t\tTARGETED_DEVICE_FAMILY = "1,2";
\t\t\t\tIPHONEOS_DEPLOYMENT_TARGET = 17.0;
\t\t\t\tVERSIONING_SYSTEM = "apple-generic";"""

target_release_settings = target_debug_settings + "\n\t\t\t\tVALIDATE_PRODUCT = YES;"

objects.append(f"\t\t{cfg_project_debug} /* Debug */ = {{isa = XCBuildConfiguration; buildSettings = {{\n{project_debug_settings}\n\t\t}}; name = Debug; }};")
objects.append(f"\t\t{cfg_project_release} /* Release */ = {{isa = XCBuildConfiguration; buildSettings = {{\n{project_release_settings}\n\t\t}}; name = Release; }};")
objects.append(f"\t\t{cfg_target_debug} /* Debug */ = {{isa = XCBuildConfiguration; buildSettings = {{\n{target_debug_settings}\n\t\t}}; name = Debug; }};")
objects.append(f"\t\t{cfg_target_release} /* Release */ = {{isa = XCBuildConfiguration; buildSettings = {{\n{target_release_settings}\n\t\t}}; name = Release; }};")

objects.append(f"\t\t{project_configlist_id} /* Build configuration list for PBXProject \"32Brockman\" */ = {{isa = XCConfigurationList; buildConfigurations = (\n\t\t\t\t{cfg_project_debug} /* Debug */,\n\t\t\t\t{cfg_project_release} /* Release */,\n\t\t\t); defaultConfigurationIsVisible = 0; defaultConfigurationName = Release; }};")
objects.append(f"\t\t{target_configlist_id} /* Build configuration list for PBXNativeTarget \"32Brockman\" */ = {{isa = XCConfigurationList; buildConfigurations = (\n\t\t\t\t{cfg_target_debug} /* Debug */,\n\t\t\t\t{cfg_target_release} /* Release */,\n\t\t\t); defaultConfigurationIsVisible = 0; defaultConfigurationName = Release; }};")

pbx = ("// !$*UTF8*$!\n{\n\tarchiveVersion = 1;\n\tclasses = {\n\t};\n\tobjectVersion = 56;\n\tobjects = {\n\n"
       + "\n\n".join(objects)
       + "\n\n\t};\n\trootObject = " + project_id + " /* Project object */;\n}")

out = pathlib.Path("32Brockman.xcodeproj/project.pbxproj")
out.parent.mkdir(parents=True, exist_ok=True)
out.write_text(pbx, encoding="utf-8")
print("WROTE", out, "files:", len(swift_files))
