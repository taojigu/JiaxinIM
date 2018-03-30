Pod::Spec.new do |s|
    s.name         = 'JiaxinIM'
    s.version      = '2.4.2'
    s.summary      = 'Custom Service Kit for JiaXin'
    s.homepage     = 'https://www.jiaxincloud.com/index.html'
    s.license      = 'MIT'
    s.authors      = {'Gujitao' => 'gujitao@dankegongyu.com'}
    s.platform     = :ios, '6.0'
    s.source       = {:git => 'https://github.com/iOSGroup/JiaxinIM.git', :tag => s.version}
    s.source_files = 'JXUIKit/**/*.{h,m,mm}','JXSDK_Lite/**/*.{h,m}'
    s.resource     = 'JXUIKit/**/*.bundle'
    s.vendored_libraries   = '**/*.{a}'
    s.requires_arc = true
    s.framework = 'CFNetwork'
    s.framework = 'SystemConfiguration'
    s.libraries = 'sqlite3','resolv','xml2','C++'
    
    s.dependency  'MJRefresh'

end
