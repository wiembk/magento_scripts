#!/bin/bash
# DESCRIPTION: Refreshes magento in one command , you can use --safe tag to make it with maintenance mode.
# It performs a specific task or operation.
if [ "$1" == "--safe" ]
then
    echo "Running in safe mode..."
    magento maintenance:enable
    magento setup:upgrade
    magento setup:di:compile
    magento setup:static-content:deploy -f
    magento cache:flush
    magento maintenance:disable
else
    echo "Running in unsafe mode..."
    magento setup:upgrade
    magento setup:di:compile
    magento setup:static-content:deploy -f
    magento cache:flush
fi












   public function canUseConfig()
    {
        if ($this->_canUseConfig === null) {
            if (strpos($this->_coreRegistry->registry('current_theme')->getData('code'), $this->themeNamespace) === 0) {
                $this->_canUseConfig = true;
            } elseif (strpos($this->_objectManager->get(\Magento\Framework\View\Design\Theme\ThemeProviderInterface::class)
                ->getThemeById($this->_coreRegistry->registry('current_theme')->getData('parent_id'))->getData('code'), $this->themeNamespace) === 0) {
                $this->_canUseConfig = true;
            } else {
                $this->_canUseConfig = false;
            }
        }
       return $this->_canUseConfig;
    }

